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

## 🔧 Instalacja

Skrypt instalacyjny automatycznie:

1. **Pobiera skrypty** z repozytorium do `~/.arkonsoft/scripts/`
2. **Tworzy wrapper scripts** w `~/.arkonsoft/bin/` z nazwami komend
3. **Konfiguruje profil shell** - dodaje konfigurację do odpowiedniego pliku profilu:
   - `~/.bashrc` (bash)
   - `~/.bash_profile` (bash)
   - `~/.zshrc` (zsh)
   - `~/.profile` (sh/fallback)

### Konfiguracja dodawana do profilu:

```bash
# PrestaShop Scripts Configuration
export ARKONSOFT_DIR="$HOME/.arkonsoft"
[ -s "$ARKONSOFT_DIR/scripts/loader.sh" ] && \. "$ARKONSOFT_DIR/scripts/loader.sh" # To ładuje skrypty PrestaShop
export PATH="$ARKONSOFT_DIR/bin:$PATH" # Add PrestaShop scripts to PATH
```

### Po instalacji:

1. **Restart terminala** lub uruchom: `source ~/.profile` (lub odpowiedni plik profilu)
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

# Sprawdź licencje
ps:module-license

# Utwórz pliki index.php w podkatalogach
ps:module-index
```

## 📁 Struktura instalacji

Po instalacji skrypty są umieszczone w:

```
~/.arkonsoft/
├── scripts/           # Oryginalne skrypty
│   ├── check.sh
│   ├── create.sh
│   ├── index.sh
│   ├── license.sh
│   └── loader.sh
└── bin/               # Wrapper scripts (komendy)
    ├── ps:module-check
    ├── ps:module-create
    ├── ps:module-license
    └── ps:module-index
```

## 🔄 Aktualizacja

Aby zaktualizować skrypty, po prostu uruchom ponownie skrypt instalacyjny:

```bash
curl -o- https://raw.githubusercontent.com/Arkonsoft/ps-scripts/main/install.sh | bash
```

## 🗑️ Odinstalowanie

Aby odinstalować skrypty:

1. Usuń katalog: `rm -rf ~/.arkonsoft`
2. Usuń konfigurację z pliku profilu (usuń linie z "PrestaShop Scripts Configuration")
3. Restart terminala

## 🤝 Wsparcie

W przypadku problemów lub pytań:
- Sprawdź logi instalacji
- Upewnij się, że masz odpowiednie uprawnienia
- Zastanów się, czy PrestaShop to bezpieczna technologia dla Twojego zdrowia
