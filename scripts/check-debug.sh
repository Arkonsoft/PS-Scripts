#!/bin/bash

set -euo pipefail

# Logging helpers
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

PATTERNS=(
    "{debug}"
    "var_dump("
    "dump("
    "console.log("
    "debugger;"
)

SEARCH_ROOTS=("themes" "modules")

build_search_directories() {
    local -a available_dirs=()

    for dir in "${SEARCH_ROOTS[@]}"; do
        if [ -d "$dir" ]; then
            available_dirs+=("$dir")
        else
            log_warning "Directory '$dir' not found. Skipping."
        fi
    done

    if [ ${#available_dirs[@]} -eq 0 ]; then
        log_error "No searchable directories (themes/modules) were found in $(pwd)."
        exit 1
    fi

    printf "%s\n" "${available_dirs[@]}"
}

search_for_pattern() {
    local pattern="$1"
    shift
    local -a dirs=("$@")

    find "${dirs[@]}" \
        -type f \
        ! -path "*/vendor/*" \
        ! -path "*/.github/*" \
        ! -path "*/node_modules/*" \
        ! -path "*/.git/*" \
        ! -name "*.min.js" \
        ! -name "*.min.css" \
        ! -name "php-cs-fixer.phar" \
        -exec grep -nH -F "$pattern" {} + 2>/dev/null || true
}

main() {
    mapfile -t dirs < <(build_search_directories)

    local found_any=0

    for pattern in "${PATTERNS[@]}"; do
        log_info "Searching for pattern: $pattern"
        matches=$(search_for_pattern "$pattern" "${dirs[@]}")

        if [ -n "$matches" ]; then
            log_error "Found debug statement pattern: $pattern"
            printf "%s\n" "$matches"
            found_any=1
        fi
    done

    if [ "$found_any" -eq 1 ]; then
        log_error "Debug statements were found."
        exit 1
    fi

    log_success "No debug statements found!"
}

main "$@"
