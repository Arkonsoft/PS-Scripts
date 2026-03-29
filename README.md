# PrestaShop Development Scripts

Zbiór przydatnych skryptów do pracy z rozwojem i zarządzaniem modułami PrestaShop. Skrypty automatyzują typowe zadania związane z tworzeniem, sprawdzaniem i zarządzaniem modułami PrestaShop.

## 🚀 Szybka instalacja

Zainstaluj skrypty jednym poleceniem:

```bash
curl -o- https://raw.githubusercontent.com/Arkonsoft/ps-scripts/main/install.sh | bash
```

lub używając wget:

```bash
wget -qO- https://raw.githubusercontent.com/Arkonsoft/ps-scripts/main/install.sh | bash
```

## 📋 Wymagania

- System Unix/Linux (Linux, macOS, WSL)
- Shell: bash, zsh, lub sh
- cURL lub wget (do instalacji)

## 🔧 Po instalacji

1. **Restart terminala** lub uruchom: `source ~/.profile`
2. **Sprawdź instalację**: `ps:module-check`
## 📦 Dostępne komendy

Po instalacji dostępne są następujące komendy:

### `ps:module-check`
Sprawdza poprawność instalacji modułu PrestaShop w bieżącym katalogu.
- Weryfikuje obecność wymaganych plików (`index.php`, `.htaccess`, `logo.png`)
- Sprawdza strukturę katalogów
- Generuje raport z błędami i ostrzeżeniami

```bash
ps:module-check
```

### `ps:check-debug`
Skanuje katalogi `themes` oraz `modules` i wyszukuje typowe ślady debugowania.
- Szuka wzorców takich jak `{debug}`, `var_dump(`, `dump(`, `console.log(`, `debugger;`
- Pomija katalogi systemowe (`vendor`, `node_modules`, `.git`, `.github`) oraz pliki zminifikowane
- Kończy działanie kodem wyjścia `1`, jeśli znajdzie debug w plikach
- Obsługuje dodatkowe instalacje PrestaShop dzięki opcji `--ip-path`, która skanuje katalogi `themes` i `modules` we wskazanych lokalizacjach

```bash
# Podstawowe użycie w bieżącym katalogu
ps:check-debug

# Dodatkowe instalacje (np. katalogi IP)
ps:check-debug --ip-path /var/www/ip1 --ip-path /var/www/ip2
```

### `ps:module-create`
Tworzy nowy moduł PrestaShop z kompletną strukturą katalogów i plików.
- Generuje podstawowe pliki modułu
- Tworzy strukturę katalogów zgodną ze standardami PrestaShop
- Konfiguruje podstawowe ustawienia

**Format nazwy:** PascalCase (np. `ArkonExample`)

```bash
ps:module-create <nazwa-modułu>
```

### `ps:docker-create`
Konfiguruje środowisko Docker dla projektu PrestaShop.
- Klonuje repozytorium PS-Docker z konfiguracją Docker
- Kopiuje pliki konfiguracyjne do bieżącego katalogu
- Aktualizuje plik `.gitignore` o odpowiednie wpisy
- Instruuje użytkownika o dalszych krokach konfiguracji

```bash
ps:docker-create
```

### `ps:module-license`
Zarządza licencjami w plikach modułu.
- Sprawdza obecność nagłówków licencyjnych
- Dodaje/aktualizuje informacje o licencji
- Weryfikuje zgodność z wymaganiami licencyjnymi

```bash
ps:module-license
```

### `ps:module-index`
Tworzy pliki `index.php` we wszystkich podkatalogach dla bezpieczeństwa.
- Kopiuje `index.php` z katalogu głównego do wszystkich podkatalogów
- Pomija katalogi systemowe (`.git`, `node_modules`, `vendor`)
- Zapewnia ochronę przed bezpośrednim dostępem do katalogów

```bash
ps:module-index
```

### `ps:module-htaccess`
Tworzy brakujące pliki `.htaccess` w katalogu modułu oraz w katalogach `log` i `logs`.
- Dodaje standardowy plik `.htaccess` chroniący pliki PHP w katalogu głównym modułu
- Dodaje rozszerzoną wersję `.htaccess` w katalogach `log`/`logs`, blokując dostęp do plików PHP i LOG
- Pomija katalogi systemowe (`vendor`, `node_modules`, `.git`, `.github`, `translations`, `override`, `tests`)
- Nie nadpisuje istniejących plików `.htaccess`

```bash
ps:module-htaccess
```

### `ps:module-change-name`
Zmienia nazwę modułu, podmieniając jej wystąpienia zarówno w zawartości plików, jak i w nazwach plików oraz katalogów.
- Automatycznie rozpoznaje i generuje warianty nazwy (`PascalCase`, `camelCase`, `snake_case`, `UPPER_SNAKE`, `lowercase`)
- Podmienia tekst w bezpiecznej kolejności (od najbardziej złożonych formatów do najprostszych)
- Zmienia nazwy plików i folderów (np. `arkonexample.php` na `arkonnowanazwa.php`)
- Pomija katalogi systemowe i ukryte (`vendor`, `node_modules`, `.git` itp.)
- Na koniec automatycznie uruchamia weryfikację modułu (`ps:module-check`)

```bash
ps:module-change-name ArkonExample ArkonNowyModul
```

## 🛠️ Użycie

Wszystkie komendy są dostępne globalnie po instalacji. Uruchom je z dowolnego katalogu:

```bash
# Sprawdź instalację modułu
ps:module-check

# Utwórz nowy moduł
ps:module-create ArkonExample

# Skonfiguruj środowisko Docker
ps:docker-create

# Sprawdź licencje
ps:module-license

# Utwórz pliki index.php w podkatalogach
ps:module-index
```

## 🔄 Aktualizacja

Aby zaktualizować skrypty, uruchom ponownie skrypt instalacyjny:

```bash
curl -o- https://raw.githubusercontent.com/Arkonsoft/ps-scripts/main/install.sh | bash
```
