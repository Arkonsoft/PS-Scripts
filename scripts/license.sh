#!/bin/bash

# Colors for output (only if terminal supports colors)
# More robust color detection
if [ -t 1 ] && [ "${TERM:-}" != "dumb" ] && [ "${TERM:-}" != "unknown" ]; then
    # Check if colors are supported
    if command -v tput >/dev/null 2>&1 && tput colors >/dev/null 2>&1 && [ "$(tput colors)" -ge 8 ]; then
        RED='\033[0;31m'
        GREEN='\033[0;32m'
        YELLOW='\033[0;33m'
        BLUE='\033[0;34m'
        NC='\033[0m' # No Color
        USE_COLORS=true
    else
        # Fallback: try to detect if we're in a modern terminal
        case "${TERM:-}" in
            xterm*|screen*|tmux*|linux*|vt100*)
                RED='\033[0;31m'
                GREEN='\033[0;32m'
                YELLOW='\033[0;33m'
                BLUE='\033[0;34m'
                NC='\033[0m'
                USE_COLORS=true
                ;;
            *)
                RED=''
                GREEN=''
                YELLOW=''
                BLUE=''
                NC=''
                USE_COLORS=false
                ;;
        esac
    fi
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    NC=''
    USE_COLORS=false
fi

# Error handling
set -euo pipefail

# Logging functions
log_info() {
    if [ "$USE_COLORS" = true ]; then
        printf "${BLUE}%s${NC}\n" "$1"
    else
        printf "[INFO] %s\n" "$1"
    fi
}

log_success() {
    if [ "$USE_COLORS" = true ]; then
        printf "${GREEN}%s${NC}\n" "$1"
    else
        printf "[SUCCESS] %s\n" "$1"
    fi
}

log_warning() {
    if [ "$USE_COLORS" = true ]; then
        printf "${YELLOW}%s${NC}\n" "$1"
    else
        printf "[WARNING] %s\n" "$1"
    fi
}

log_error() {
    if [ "$USE_COLORS" = true ]; then
        printf "${RED}%s${NC}\n" "$1" >&2
    else
        printf "[ERROR] %s\n" "$1" >&2
    fi
}

# Check if we're in a directory with PHP files
if ! find . -name "*.php" -type f -not -path "*/vendor/*" -not -path "*/node_modules/*" | grep -q .; then
    log_error "Error: No PHP files found in current directory or subdirectories"
    log_info "Please run this script from a directory containing PHP files"
    exit 1
fi

# Initialize counters
TOTAL_FILES=0
FILES_WITH_LICENSE=0
FILES_WITHOUT_LICENSE=0

log_info "Checking PHP files for license headers in all subdirectories..."

# Find all PHP files recursively, excluding node_modules and vendor
while IFS= read -r -d '' file; do
    TOTAL_FILES=$((TOTAL_FILES + 1))
    
    # Check if file contains license notice
    if grep -q "NOTICE OF LICENSE" "$file"; then
        log_success "✓ License found: $file"
        FILES_WITH_LICENSE=$((FILES_WITH_LICENSE + 1))
    else
        log_error "✗ Missing license: $file"
        FILES_WITHOUT_LICENSE=$((FILES_WITHOUT_LICENSE + 1))
    fi
done < <(find . -name "*.php" -type f -not -path "*/\.*" -not -path "*/node_modules/*" -not -path "*/vendor/*" -not -path "*/translations/*" -not -path "*/tests/*" -print0)

# Print summary
log_info "License check completed"
log_info "Total PHP files checked: $TOTAL_FILES"
log_success "$FILES_WITH_LICENSE files have proper license headers"
if [ $FILES_WITHOUT_LICENSE -gt 0 ]; then
    log_error "$FILES_WITHOUT_LICENSE files are missing license headers"
else
    log_success "All PHP files have proper license headers"
fi

