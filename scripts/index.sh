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
