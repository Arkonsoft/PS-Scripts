#!/bin/bash

# Simple text-based output without colors
set -euo pipefail

# Zapamiętanie ścieżki początkowej i bezpieczny powrót na końcu (lub w przypadku błędu)
START_DIR=$(pwd)
cleanup() {
    cd "$START_DIR" || exit 1
}
trap cleanup EXIT

# Logging functions
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

if [ $# -lt 2 ]; then
    log_error "Użycie: $0 <stara_nazwa> <nowa_nazwa>"
    log_info "Skrypt należy uruchamiać w katalogu 'modules/'"
    log_info "Przykład: $0 arkon_example arkon_super_module"
    exit 1
fi

# Usuwamy ewentualne ukośniki na końcu podane przez autouzupełnianie (np. arkon_example/)
OLD_DIR_NAME="${1%/}"
NEW_DIR_NAME="${2%/}"

if [ ! -d "$OLD_DIR_NAME" ]; then
    log_error "Błąd: Katalog modułu '$OLD_DIR_NAME' nie istnieje w obecnej lokalizacji."
    exit 1
fi

if [ -d "$NEW_DIR_NAME" ]; then
    log_error "Błąd: Katalog docelowy '$NEW_DIR_NAME' już istnieje. Przerwano."
    exit 1
fi

# Normalizacja wejścia
normalize() {
    echo "$1" | sed -E 's/([a-z])([A-Z])/\1 \2/g' | tr '_-' '  ' | tr '[:upper:]' '[:lower:]' | tr -s ' '
}

OLD_NORM=$(normalize "$OLD_DIR_NAME")
NEW_NORM=$(normalize "$NEW_DIR_NAME")

# Generowanie wariantów
generate_variants() {
    local norm_str="$1"
    
    local pascal=$(echo "$norm_str" | awk '{for(i=1;i<=NF;i++) printf toupper(substr($i,1,1)) tolower(substr($i,2));} END{print ""}')
    local camel=$(echo "$pascal" | awk '{print tolower(substr($0,1,1)) substr($0,2)}')
    local snake=$(echo "$norm_str" | tr ' ' '_')
    local upper_snake=$(echo "$snake" | tr '[:lower:]' '[:upper:]')
    local lower=$(echo "$norm_str" | tr -d ' ')

    echo "$upper_snake $pascal $camel $snake $lower"
}

read -r OLD_UPPER OLD_PASCAL OLD_CAMEL OLD_SNAKE OLD_LOWER <<< "$(generate_variants "$OLD_NORM")"
read -r NEW_UPPER NEW_PASCAL NEW_CAMEL NEW_SNAKE NEW_LOWER <<< "$(generate_variants "$NEW_NORM")"

OLD_VARS=("$OLD_UPPER" "$OLD_PASCAL" "$OLD_CAMEL" "$OLD_SNAKE" "$OLD_LOWER")
NEW_VARS=("$NEW_UPPER" "$NEW_PASCAL" "$NEW_CAMEL" "$NEW_SNAKE" "$NEW_LOWER")

log_info "Rozpoczynam modyfikację modułu: $OLD_DIR_NAME"

# Podmiana tekstu w plikach
replace_text() {
    local search_text="$1"
    local replace_text="$2"
    
    if [ -z "$search_text" ] || [ "$search_text" = "$replace_text" ]; then return; fi
    
    # Escape dla bezpieczeństwa
    local search_escaped
    local replace_escaped
    search_escaped=$(printf '%s' "$search_text" | sed 's/[.[\*^$\/&\\]/\\&/g')
    replace_escaped=$(printf '%s' "$replace_text" | sed 's/[&\\/]/\\&/g')
    
    while IFS= read -r -d '' file; do
        if grep -F -q -- "$search_text" "$file"; then
            sed -i.bak "s/${search_escaped}/${replace_escaped}/g" "$file"
            rm -f "${file}.bak"
        fi
    done < <(find "$OLD_DIR_NAME" -type f \( \
        -name "*.php"  -o -name "*.tpl"  -o -name "*.html" -o -name "*.htm"  -o \
        -name "*.js"   -o -name "*.css"  -o -name "*.scss" -o -name "*.less" -o \
        -name "*.json" -o -name "*.yml"  -o -name "*.yaml" -o -name "*.xml"  -o \
        -name "*.md"   -o -name "*.txt"  -o -name "*.ini"  -o -name "*.sh"   -o \
        -name "*.twig" \
    \) -not -path "*/\.*" -not -path "*/vendor/*" -not -path "*/node_modules/*" -print0)
}

# Zmiana nazw plików i katalogów (bez katalogu głównego!)
rename_items() {
    local search_text="$1"
    local replace_text="$2"
    
    if [ -z "$search_text" ] || [ "$search_text" = "$replace_text" ]; then return; fi
    
    # Używamy -mindepth 1 aby nie zmieniać nazwy głównego folderu podczas pętli
    while IFS= read -r -d '' item; do
        dir=$(dirname "$item")
        base=$(basename "$item")
        
        if [[ "$base" == *"$search_text"* ]]; then
            new_base="${base//$search_text/$replace_text}"
            log_warning " Zmieniono: $base -> $new_base"
            mv "$item" "$dir/$new_base"
        fi
    done < <(find "$OLD_DIR_NAME" -mindepth 1 -depth -name "*$search_text*" -not -path "*/\.*" -not -path "*/vendor/*" -not -path "*/node_modules/*" -print0)
}

log_info "Podmiana zawartości plików..."
for i in "${!OLD_VARS[@]}"; do
    replace_text "${OLD_VARS[$i]}" "${NEW_VARS[$i]}"
done

log_info "Zmiana nazw plików i podkatalogów..."
for i in "${!OLD_VARS[@]}"; do
    rename_items "${OLD_VARS[$i]}" "${NEW_VARS[$i]}"
done

# Zmiana nazwy głównego katalogu na samym końcu
log_info "Zmiana nazwy głównego katalogu modułu..."
mv "$OLD_DIR_NAME" "$NEW_DIR_NAME"
log_success "Zmieniono nazwę folderu na: $NEW_DIR_NAME"

# Weryfikacja gotowego modułu
log_info "Weryfikacja struktury modułu..."

# Przechodzimy do nowego folderu tylko na czas testu
cd "$NEW_DIR_NAME" || exit 1

if command -v ps:module-check >/dev/null 2>&1; then
    ps:module-check
elif [ -f "./check.sh" ]; then
    ./check.sh
else
    log_warning "Pominięto automatyczną weryfikację. Brak skryptu check.sh."
fi

log_success "Proces zmiany nazwy zakończony sukcesem! Nazwa modułu $OLD_DIR_NAME została pomyślnie zmieniona na: $NEW_DIR_NAME"