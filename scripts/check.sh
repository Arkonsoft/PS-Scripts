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

# Function to ensure PHP namespace is declared after allowed statements only
check_php_namespace_structure() {
    local file="$1"
    local has_namespace="false"
    local namespace_line=0
    local line_number=0
    local in_multiline_comment="false"
    local line=""
    local line_no_comment=""
    local line_trimmed=""
    local check_failed="false"

    # First pass: detect namespace line number (ignoring comments)
    while IFS= read -r line || [ -n "$line" ]; do
        line_number=$((line_number + 1))

        if [[ "$line" =~ /\* ]] && [[ "$line" =~ \*/ ]]; then
            continue
        elif [[ "$line" =~ /\* ]]; then
            in_multiline_comment="true"
            continue
        elif [[ "$line" =~ \*/ ]]; then
            in_multiline_comment="false"
            continue
        fi

        if [ "$in_multiline_comment" = "true" ]; then
            continue
        fi

        line_no_comment=$(echo "$line" | sed 's|//.*||')
        line_trimmed=$(echo "$line_no_comment" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

        [ -z "$line_trimmed" ] && continue

        if [[ "$line_trimmed" =~ ^namespace[[:space:]]+ ]]; then
            has_namespace="true"
            namespace_line=$line_number
            break
        fi
    done < "$file"

    if [ "$has_namespace" = "false" ]; then
        return 0
    fi

    # Second pass: ensure only allowed statements exist before namespace
    line_number=0
    in_multiline_comment="false"

    while IFS= read -r line || [ -n "$line" ]; do
        line_number=$((line_number + 1))

        if [ "$line_number" -ge "$namespace_line" ]; then
            break
        fi

        if [[ "$line" =~ /\* ]] && [[ "$line" =~ \*/ ]]; then
            continue
        elif [[ "$line" =~ /\* ]]; then
            in_multiline_comment="true"
            continue
        elif [[ "$line" =~ \*/ ]]; then
            in_multiline_comment="false"
            continue
        fi

        if [ "$in_multiline_comment" = "true" ]; then
            continue
        fi

        line_no_comment=$(echo "$line" | sed 's|//.*||')
        line_trimmed=$(echo "$line_no_comment" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

        [ -z "$line_trimmed" ] && continue

        if [[ "$line_trimmed" =~ ^\<\?php ]] || [[ "$line_trimmed" = "<?php" ]] || [[ "$line_trimmed" =~ ^\<\?\= ]]; then
            continue
        fi

        if [[ "$line_trimmed" =~ ^declare[[:space:]]*\([[:space:]]*strict_types[[:space:]]*=[[:space:]]*1[[:space:]]*\)[[:space:]]*\;?[[:space:]]*$ ]]; then
            continue
        fi

        log_error "PHP file has content before namespace declaration (only comments and declare strict allowed): $file (line $line_number: $line_trimmed)"
        check_failed="true"
        break
    done < "$file"

    # Third pass: ensure file contains code beyond namespace/declare/comments
    if [ "$check_failed" = "false" ]; then
        local has_other_content="false"
        line_number=0
        in_multiline_comment="false"

        while IFS= read -r line || [ -n "$line" ]; do
            line_number=$((line_number + 1))

            if [[ "$line" =~ /\* ]] && [[ "$line" =~ \*/ ]]; then
                continue
            elif [[ "$line" =~ /\* ]]; then
                in_multiline_comment="true"
                continue
            elif [[ "$line" =~ \*/ ]]; then
                in_multiline_comment="false"
                continue
            fi

            if [ "$in_multiline_comment" = "true" ]; then
                continue
            fi

            line_no_comment=$(echo "$line" | sed 's|//.*||')
            line_trimmed=$(echo "$line_no_comment" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

            [ -z "$line_trimmed" ] && continue

            if [[ "$line_trimmed" =~ ^\<\?php ]] || [[ "$line_trimmed" = "<?php" ]] || [[ "$line_trimmed" =~ ^\<\?\= ]]; then
                continue
            fi

            if [[ "$line_trimmed" =~ ^declare[[:space:]]*\([[:space:]]*strict_types[[:space:]]*=[[:space:]]*1[[:space:]]*\)[[:space:]]*\;?[[:space:]]*$ ]]; then
                continue
            fi

            if [[ "$line_trimmed" =~ ^namespace[[:space:]]+ ]]; then
                continue
            fi

            has_other_content="true"
            break
        done < "$file"

        if [ "$has_other_content" = "false" ]; then
            log_error "PHP file contains only declare strict and/or namespace (no actual code): $file"
            check_failed="true"
        fi
    fi

    if [ "$check_failed" = "true" ]; then
        return 1
    fi

    return 0
}

# Function to check if a file exists
check_file_exists() {
    if [ ! -f "$1" ]; then
        log_error "Missing required file: $1"
    fi
}

# Function to check if index.php exists and is not empty
check_index_file() {
    local file_path="$1"
    if [ ! -f "$file_path" ]; then
        log_error "Missing required file: $file_path"
        error_count=$((error_count + 1))
    elif [ ! -s "$file_path" ]; then
        log_error "index.php cannot be empty: $file_path"
        error_count=$((error_count + 1))
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
        check_index_file "$dir/index.php"
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

        if ! check_php_namespace_structure "$php_file"; then
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
