#!/bin/sh

# Constants
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Error handling
set -e

# Logging functions
log_info() {
    echo "${BLUE}$1${NC}"
}

log_success() {
    echo "${GREEN}$1${NC}"
}

log_warning() {
    echo "${YELLOW}$1${NC}"
}

log_error() {
    echo "${RED}$1${NC}" >&2
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
find . -name "*.php" -type f -not -path "*/\.*" -not -path "*/node_modules/*" -not -path "*/vendor/*" -not -path "*/translations/*" -not -path "*/tests/*" | while read file; do
    TOTAL_FILES=$((TOTAL_FILES + 1))
    
    # Check if file contains license notice
    if grep -q "NOTICE OF LICENSE" "$file"; then
        log_success "✓ License found: $file"
        FILES_WITH_LICENSE=$((FILES_WITH_LICENSE + 1))
    else
        log_error "✗ Missing license: $file"
        FILES_WITHOUT_LICENSE=$((FILES_WITHOUT_LICENSE + 1))
    fi
done

# Print summary
log_info "License check completed"
log_info "Total PHP files checked: $TOTAL_FILES"
log_success "$FILES_WITH_LICENSE files have proper license headers"
if [ $FILES_WITHOUT_LICENSE -gt 0 ]; then
    log_error "$FILES_WITHOUT_LICENSE files are missing license headers"
else
    log_success "All PHP files have proper license headers"
fi

