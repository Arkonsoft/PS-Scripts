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
EXCLUDE_PATHS=()

usage() {
    cat <<'EOF'
Usage: ps:check-debug [options]

Options:
  --exclude <path>   Path to a file or directory that should be skipped.
                     Repeat the flag to add multiple paths.
  --help             Show this message.
EOF
}

add_exclude_path() {
    local raw="$1"

    if [ -z "$raw" ]; then
        log_warning "Empty path provided to --exclude. Skipping."
        return
    fi

    local sanitized="${raw%/}"
    local root="${PWD%/}"

    if [[ "$sanitized" == "$root" ]]; then
        log_warning "Exclude path '$raw' resolves to the repository root. Skipping."
        return
    fi

    if [[ "$sanitized" == "$root/"* ]]; then
        sanitized="${sanitized#"$root/"}"
    fi

    sanitized="${sanitized#./}"

    if [ -z "$sanitized" ]; then
        log_warning "Exclude path '$raw' resolves to an empty value. Skipping."
        return
    fi

    EXCLUDE_PATHS+=("$sanitized")
}

parse_args() {
    while (($#)); do
        case "$1" in
            --exclude)
                shift || {
                    log_error "Missing value for --exclude"
                    usage
                    exit 1
                }
                add_exclude_path "$1"
                ;;
            --exclude=*)
                add_exclude_path "${1#*=}"
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
        shift || true
    done
}

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
    local -a find_args=(
        "${dirs[@]}"
        -type f
        ! -path "*/vendor/*"
        ! -path "*/.github/*"
        ! -path "*/node_modules/*"
        ! -path "*/.git/*"
        ! -name "*.min.js"
        ! -name "*.min.css"
        ! -name "php-cs-fixer.phar"
    )

    if [ ${#EXCLUDE_PATHS[@]} -gt 0 ]; then
        for exclude_path in "${EXCLUDE_PATHS[@]}"; do
            find_args+=(! -path "$exclude_path")
            find_args+=(! -path "$exclude_path/*")
        done
    fi

    find "${find_args[@]}" \
        -exec grep -nH -F "$pattern" {} + 2>/dev/null || true
}

main() {
    parse_args "$@"

    mapfile -t dirs < <(build_search_directories)

    if [ ${#EXCLUDE_PATHS[@]} -gt 0 ]; then
        log_info "The following paths will be skipped:"
        for excluded in "${EXCLUDE_PATHS[@]}"; do
            log_info "  - $excluded"
        done
    fi

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
