#!/bin/bash

# Colors for output (only if terminal supports colors)
if [ -t 1 ] && [ "${TERM:-}" != "dumb" ] && command -v tput >/dev/null 2>&1 && tput colors >/dev/null 2>&1; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    BLUE='\033[0;34m'
    NC='\033[0m' # No Color
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    NC=''
fi

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

# Check if index.php exists in current directory
if [ ! -f "index.php" ]; then
    log_error "Error: index.php not found in current directory"
    log_info "Please run this script from a directory containing an index.php file"
    exit 1
fi

# Get the content of the index.php file
INDEX_CONTENT=$(cat index.php)

# Count of created/updated files
CREATED_COUNT=0
SKIPPED_COUNT=0

log_info "Starting to copy index.php to all subdirectories..."
log_warning "Source index.php: $(pwd)/index.php"

# Find all directories recursively, excluding node_modules and vendor
while IFS= read -r -d '' dir; do
    # Skip current directory
    if [ "$dir" = "." ]; then
        continue
    fi
    
    # Check if directory exists and is accessible
    if [ -d "$dir" ]; then
        if [ -f "$dir/index.php" ]; then
            log_warning "Skipping: $dir/index.php (already exists)"
            SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
        else
            echo "$INDEX_CONTENT" > "$dir/index.php"
            if [ $? -eq 0 ]; then
                log_success "Created: $dir/index.php"
                CREATED_COUNT=$((CREATED_COUNT + 1))
            else
                log_error "Failed to create: $dir/index.php"
            fi
        fi
    fi
done < <(find . -type d -not -path "*/\.*" -not -path "*/node_modules/*" -not -path "*/vendor/*" -print0)

log_info "Process completed"
log_success "Created $CREATED_COUNT index.php files"
log_warning "Skipped $SKIPPED_COUNT existing index.php files"
