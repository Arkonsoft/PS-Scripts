#!/bin/bash

# Simple text-based output without colors

# Error handling
set -euo pipefail

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

# Function to check if a file exists
check_file_exists() {
    if [ ! -f "$1" ]; then
        log_error "Missing required file: $1"
    fi
}

# Function to check if .htaccess exists and is not empty
check_htaccess_file() {
    local file_path="$1"
    if [ ! -f "$file_path" ]; then
        log_error "Missing required file: $file_path"
        error_count=$((error_count + 1))
    elif [ ! -s "$file_path" ]; then
        log_error ".htaccess cannot be empty: $file_path"
        error_count=$((error_count + 1))
    fi
}

# Function to check PHP file header
check_php_header() {
    if ! grep -q "!defined('_PS_VERSION_')" "$1"; then
        log_error "Missing PrestaShop version check in: $1"
    fi
}

# Function to check PHP license header
check_php_license() {
    if ! grep -q "NOTICE OF LICENSE" "$1"; then
        log_error "Missing license notice in: $1"
    fi
}

# Function to check composer.json
check_composer_json() {
    if [ -f "$1" ]; then
        if ! grep -q '"prepend-autoloader": false' "$1"; then
            log_error "Missing or incorrect 'prepend-autoloader' setting in: $1 (should be set to false)"
        fi
    fi
}

# Function to check if uninstall method uses unregisterHook (should NOT be present)
check_uninstall_unregister_hook() {
    local file="$1"
    if grep -q 'function uninstall' "$file"; then
        if grep -Eq 'unregisterHook\s*\(' "$file"; then
            log_error "unregisterHook should NOT be used in uninstall method of: $file"
        fi
    fi
}

# Function to check for translation functions in constructor for blgn modules (should NOT be present)
check_blgn_constructor_translations() {
    local file="$1"
    if grep -q 'function __construct' "$file"; then
        constructor_lines=$(awk '/function __construct/{flag=1} /function [^_]|^}/ {if(flag){flag=0}} flag' "$file")
        if echo "$constructor_lines" | grep -E '\$this->l\(|this->getTranslator\(|\$this->trans\('; then
            log_error "Translation function should NOT be used in constructor in: $file"
        fi
    fi
}

# Main execution
main() {
    module_path="."
    module_name=$(basename "$PWD")
    error_count=0
    
    log_info "Starting module checks for: $module_name ($module_path)"

    # 1. Check for index.php in all directories (except excluded directories)
    excluded_dirs=("vendor" "node_modules" ".github" ".git")
    while IFS= read -r -d '' dir; do
        if [ ! -f "$dir/index.php" ]; then
            log_error "Missing required file: $dir/index.php"
            error_count=$((error_count + 1))
        fi
    done < <(find "$module_path" -type d \( -name "vendor" -o -name "node_modules" -o -name ".github" -o -name ".git" -o -name ".webpack" \) -prune -o -type d -print0)

    # 2. Check .htaccess in main module directory
    check_htaccess_file "$module_path/.htaccess"

    # 3. Check for logo.png
    if [ ! -f "$module_path/logo.png" ]; then
        log_error "Missing required file: $module_path/logo.png"
        error_count=$((error_count + 1))
    fi

    # 4. Check PHP files for version check and license (excluding excluded directories and files)
    while IFS= read -r -d '' php_file; do
        if ! grep -q "!defined('_PS_VERSION_')" "$php_file"; then
            log_error "Missing PrestaShop version check in: $php_file"
            error_count=$((error_count + 1))
        fi
        
        if ! grep -q "NOTICE OF LICENSE" "$php_file"; then
            log_error "Missing license notice in: $php_file"
            error_count=$((error_count + 1))
        fi
        
        # Check for unregisterHook in uninstall method in main module file
        case "$php_file" in
            "$module_path/"*.php)
                if grep -q 'function uninstall' "$php_file"; then
                    if grep -Eq 'unregisterHook\s*\(' "$php_file"; then
                        log_error "unregisterHook should NOT be used in uninstall method of: $php_file"
                        error_count=$((error_count + 1))
                    fi
                fi
                
                # If module starts with blgn, check for translation functions in constructor
                if echo "$module_name" | grep -q '^blgn'; then
                    if grep -q 'function __construct' "$php_file"; then
                        constructor_lines=$(awk '/function __construct/{flag=1} /function [^_]|^}/ {if(flag){flag=0}} flag' "$php_file")
                        if echo "$constructor_lines" | grep -E '\$this->l\(|this->getTranslator\(|\$this->trans\('; then
                            log_error "Translation function should NOT be used in constructor in: $php_file"
                            error_count=$((error_count + 1))
                        fi
                    fi
                fi
                ;;
        esac
    done < <(find "$module_path" \( -path "*/vendor" -o -path "*/node_modules" -o -path "*/.github" -o -path "*/.git" -o -path "*/translations" -o -path "*/tests" -o -path "*/override" \) -prune -o -name "*.php" ! -name "index.php" ! -name "*cs-fixer*" -type f -print0)

    # 5. Check .htaccess in log directories
    for log_dir in "$module_path/log" "$module_path/logs"; do
        if [ -d "$log_dir" ]; then
            check_htaccess_file "$log_dir/.htaccess"
        fi
    done

    # 6. Check composer.json
    if [ -f "$module_path/composer.json" ]; then
        if ! grep -q '"prepend-autoloader": false' "$module_path/composer.json"; then
            log_error "Missing or incorrect 'prepend-autoloader' setting in: $module_path/composer.json (should be set to false)"
            error_count=$((error_count + 1))
        fi
    fi

    # Display summary
    if [ $error_count -gt 0 ]; then
        log_error "Found $error_count errors."
        exit 1
    else
        log_success "All checks passed successfully!"
        exit 0
    fi
}

main "$@"
