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

EXAMPLE_LOWER="arkonexample"
EXAMPLE_PASCAL="ArkonExample"
GITHUB_REPO="https://github.com/Arkonsoft/PS-Example-Module-8.git"

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

# Utility functions
to_lower() {
    echo "${1,,}"
}

to_pascal() {
    echo "${1^}"
}

# Validation functions
validate_input() {
    if [ $# -lt 1 ]; then
        log_error "Error: Module name is required"
        echo "Usage: $0 <module_name>"
        exit 1
    fi

    # Check if module name contains only valid characters
    if [[ ! "$1" =~ ^[a-zA-Z][a-zA-Z0-9]*$ ]]; then
        log_error "Error: Module name must start with a letter and contain only letters and numbers"
        exit 1
    fi
}

check_composer() {
    if ! command -v composer >/dev/null 2>&1; then
        log_error "ERROR: Composer is not installed or not available in PATH"
        log_warning "Please install Composer before running this script: https://getcomposer.org/"
        exit 1
    fi
    log_success "Composer detected: $(composer --version)"
}

# Module initialization functions
initialize_module_names() {
    module_name=$1
    MODULE_LOWER=$(to_lower "$module_name")
    MODULE_PASCAL=$(to_pascal "$module_name")
}

show_module_configuration() {
    log_info "Module configuration:"
    log_warning "- Module name (lower): $MODULE_LOWER"
    log_warning "- Module name (pascal): $MODULE_PASCAL"
    log_warning "- Target folder: $PWD"
}

get_target_path() {
    module_name=$1
    current_folder=$(basename "$PWD")
    
    if [ "$current_folder" = "$module_name" ]; then
        echo "$PWD"
    else
        echo "$PWD/$module_name"
    fi
}

initialize_module_repository() {
    target_path=$1
    
    log_info "Cloning module from repository..."
    
    if ! git clone "$GITHUB_REPO" "$target_path"; then
        log_error "Error while cloning module"
        exit 1
    fi

    cd "$target_path"
    rm -rf .git 2>/dev/null
    log_success "Module cloned successfully"
}

# File operations
replace_text_in_files() {
    local search_text="$1"
    local replace_text="$2"
    
    while IFS= read -r -d '' file; do
        if [ -s "$file" ]; then
            log_warning "Processing file: $(basename "$file")"
            
            if grep -q "$search_text" "$file"; then
                sed -i "s/$search_text/$replace_text/g" "$file"
                log_success "  Changes made to file"
            else
                echo "  No changes needed"
            fi
        fi
    done < <(find . -type f -not -path "*/\.*" -not -path "*/vendor/*" -print0)
}

rename_module_files() {
    log_info "Renaming files..."
    
    while IFS= read -r -d '' file; do
        filename=$(basename "$file")
        directory=$(dirname "$file")
        newname="$filename"
        
        case "$filename" in
            *"$EXAMPLE_LOWER"*)
                newname=$(echo "$newname" | sed "s/$EXAMPLE_LOWER/$MODULE_LOWER/g")
                ;;
            *"$EXAMPLE_PASCAL"*)
                newname=$(echo "$newname" | sed "s/$EXAMPLE_PASCAL/$MODULE_PASCAL/g")
                ;;
        esac
        
        if [ "$newname" != "$filename" ]; then
            log_warning "Renaming: $filename -> $newname"
            mv "$file" "$directory/$newname"
        fi
    done < <(find . -type f -not -path "*/\.*" -not -path "*/vendor/*" -print0)
}

install_module_dependencies() {
    log_info "Running composer install..."
    
    if ! composer install; then
        log_error "Error running composer install"
        exit 1
    fi
    log_success "Composer install completed successfully"
}

confirm_module_location() {
    current_folder=$(basename "$PWD")
    
    if [ "$current_folder" != "modules" ]; then
        log_error "WARNING: You are not in a 'modules' folder!"
        log_warning "Creating modules outside of a 'modules' directory is not recommended."
        
        printf "Do you want to continue anyway? (y/N) "
        read confirmation
        case "$confirmation" in
            [yY])
                ;;
            *)
                log_info "Operation cancelled by user"
                exit 0
                ;;
        esac
    fi
}

delete_readme_and_github() {
    log_info "Deleting README.md and .github directory..."
    
    if [ -f "README.md" ]; then
        rm "README.md"
        log_success "README.md deleted successfully"
    else
        log_warning "README.md not found"
    fi
    
    if [ -d ".github" ]; then
        rm -rf ".github"
        log_success ".github directory deleted successfully"
    else
        log_warning ".github directory not found"
    fi
}

# Main execution
main() {
    validate_input "$@"
    check_composer
    original_location="$PWD"
    confirm_module_location

    initialize_module_names "$1"
    show_module_configuration
    target_path=$(get_target_path "$MODULE_LOWER")
    initialize_module_repository "$target_path"

    # Replace module names
    log_warning "Replacing lowercase names..."
    replace_text_in_files "$EXAMPLE_LOWER" "$MODULE_LOWER"

    log_warning "Replacing PascalCase names..."
    replace_text_in_files "$EXAMPLE_PASCAL" "$MODULE_PASCAL"

    # Rename files and install dependencies
    rename_module_files
    delete_readme_and_github
    install_module_dependencies

    # Return to original location
    cd "$original_location"

    log_info "Module configuration completed successfully"
    log_warning "Module location: $target_path"
}

# Execute main function
main "$@"
