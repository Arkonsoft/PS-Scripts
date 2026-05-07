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

