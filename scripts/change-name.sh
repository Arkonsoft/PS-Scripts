#!/bin/bash

set -euo pipefail

# Zapamiętanie ścieżki początkowej dla bezpiecznego powrotu
START_DIR=$(pwd)
cleanup() { cd "$START_DIR" || exit 1; }
trap cleanup EXIT

# Funkcje logowania
log_info() {
    printf "[INFO] %s\n" "$1"
}

log_success() {
    printf "[SUCCESS] %s\n" "$1"
}

log_warning() {
    printf "[WARNING] %s\n" "$1"
}

log_error() {
    printf "[ERROR] %s\n" "$1" >&2
}

# Walidacja wejścia
if [ $# -lt 2 ]; then
    log_error "Użycie: ps:module-change-name <ObecnaNazwaModułu> <NazwaNowaModułu>"
    log_info "Przykład: ps:module-change-name arkon_test DediNewModule"
    exit 1
fi

INPUT_OLD="${1%/}"
INPUT_NEW="$2"

# Lokalizacja folderu (wyszukiwanie ignorujące wielkość liter)
OLD_DIR_NAME=$(find . -maxdepth 1 -type d -iname "$INPUT_OLD" -printf '%f\n' -quit)

if [ -z "$OLD_DIR_NAME" ]; then
    log_error "Nie znaleziono folderu pasującego do '$INPUT_OLD' w bieżącej lokalizacji."
    exit 1
fi

# Inicjalizacja liczników
FILES_CHANGED=0
NAMES_RENAMED=0

# Narzędzia do transformacji tekstu
tokenize() {
    echo "$1" | sed -E 's/([a-z0-9])([A-Z])/\1 \2/g' | tr '_-' '  ' | tr '[:upper:]' '[:lower:]' | tr -s ' '
}

get_formats() {
    local p="$1" # PascalCase
    local s=$(echo "$p" | sed -E 's/([a-z0-9])([A-Z])/\1_\2/g' | tr '[:upper:]' '[:lower:]')
    local c=$(echo "$p" | awk '{print tolower(substr($0,1,1)) substr($0,2)}')
    local u=$(echo "$s" | tr '[:lower:]' '[:upper:]')
    local l=$(echo "$s" | tr -d '_')
    echo "$u $p $c $s $l"
}

# Detekcja nazw (Źródło prawdy: klasa w głównym pliku PHP)
MAIN_PHP="$OLD_DIR_NAME/$OLD_DIR_NAME.php"
OLD_PASCAL=""

if [ -f "$MAIN_PHP" ]; then
    # Wyciąga nazwę klasy bezpośrednio z definicji PHP
    OLD_PASCAL=$(grep -m 1 "^class " "$MAIN_PHP" | sed -E 's/.*class ([a-zA-Z0-9_]+).*/\1/' || echo "")
fi

# Fallback: jeśli nie wykryto klasy, zgadujemy na podstawie nazwy folderu
if [ -z "$OLD_PASCAL" ]; then
    OLD_PASCAL=$(tokenize "$OLD_DIR_NAME" | awk '{for(i=1;i<=NF;i++) printf toupper(substr($i,1,1)) tolower(substr($i,2));}')
    log_warning "Nie wykryto klasy w $MAIN_PHP. Użyto wygenerowanej nazwy: $OLD_PASCAL"
fi

# Ustalanie nowej nazwy (PascalCase)
NEW_PASCAL=$(tokenize "$INPUT_NEW" | awk '{for(i=1;i<=NF;i++) printf toupper(substr($i,1,1)) tolower(substr($i,2));}')

# Generowanie mapy wariantów
read -r O_UPPER O_PASCAL O_CAMEL O_SNAKE O_LOWER <<< "$(get_formats "$OLD_PASCAL")"
read -r N_UPPER N_PASCAL N_CAMEL N_SNAKE N_LOWER <<< "$(get_formats "$NEW_PASCAL")"

OLD_VARS=("$O_UPPER" "$O_PASCAL" "$O_CAMEL" "$O_SNAKE" "$O_LOWER")
NEW_VARS=("$N_UPPER" "$N_PASCAL" "$N_CAMEL" "$N_SNAKE" "$N_LOWER")

log_info "Zidentyfikowano moduł: $OLD_PASCAL -> $NEW_PASCAL"

# Proces podmiany zawartości
log_info "Aktualizacja zawartości plików..."

for i in "${!OLD_VARS[@]}"; do
    search="${OLD_VARS[$i]}"
    replace="${NEW_VARS[$i]}"
    
    [ "$search" == "$replace" ] && continue

    # Escapowanie znaków dla sed
    search_esc=$(printf '%s' "$search" | sed 's/[.[\*^$\/&\\]/\\&/g')
    replace_esc=$(printf '%s' "$replace" | sed 's/[&\\/]/\\&/g')
    
    # Przeszukiwanie i podmiana z wykluczeniem folderów systemowych
    while IFS= read -r -d '' file; do
        if grep -F -q "$search" "$file"; then
            sed -i "s/${search_esc}/${replace_esc}/g" "$file"
            FILES_CHANGED=$((FILES_CHANGED + 1))
        fi
    done < <(find "$OLD_DIR_NAME" -type f \( -name "*.php" -o -name "*.tpl" -o -name "*.json" -o -name "*.yml" -o -name "*.md" -o -name "*.js" -o -name "*.css" \) \
        -not -path "*/vendor/*" -not -path "*/node_modules/*" -not -path "*/.git/*" -print0)
done

# Zmiana nazw plików i podkatalogów
log_info "Zmiana nazw plików i katalogów..."

for i in "${!OLD_VARS[@]}"; do
    search="${OLD_VARS[$i]}"
    replace="${NEW_VARS[$i]}"
    
    [ "$search" == "$replace" ] && continue

    while IFS= read -r -d '' item; do
        dir=$(dirname "$item")
        base=$(basename "$item")
        if [[ "$base" == *"$search"* ]]; then
            new_base="${base//$search/$replace}"
            mv "$item" "$dir/$new_base"
            NAMES_RENAMED=$((NAMES_RENAMED + 1))
        fi
    done < <(find "$OLD_DIR_NAME" -mindepth 1 -depth -name "*$search*" -not -path "*/vendor/*" -print0)
done

# Finalizacja: Zmiana katalogu głównego
NEW_DIR_NAME="$N_LOWER"

# Zabezpieczenie przed zagnieżdżaniem folderów
if [ -d "$NEW_DIR_NAME" ] && [ "$OLD_DIR_NAME" != "$NEW_DIR_NAME" ]; then
    log_error "Błąd: Katalog docelowy '$NEW_DIR_NAME' już istnieje. Przerwano zmianę nazwy folderu głównego, aby uniknąć zagnieżdżenia."
    exit 1
fi

mv "$OLD_DIR_NAME" "$NEW_DIR_NAME"

log_success "Proces zakończony pomyślnie! Zmieniono nazwę modułu $OLD_DIR_NAME na $NEW_DIR_NAME"
log_info "Podsumowanie zmian:"
log_success "- Nowa nazwa modułu: $NEW_DIR_NAME"
log_success "- Nowa nazwa klasy: $NEW_PASCAL"
log_warning "- Zmodyfikowane pliki: $FILES_CHANGED"
log_warning "- Zmienione nazwy elementów: $NAMES_RENAMED"

# Automatyczna weryfikacja
log_info "Uruchamianie weryfikacji po zmianie nazwy..."
cd "$NEW_DIR_NAME"
if [ -f "../check.sh" ]; then
    ../check.sh
elif command -v ps:module-check >/dev/null 2>&1; then
    ps:module-check
else
    log_warning "Nie znaleziono skryptu weryfikacyjnego. Pomijanie."
fi