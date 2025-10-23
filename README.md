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
