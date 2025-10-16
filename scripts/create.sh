#!/bin/sh

# Constants
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

EXAMPLE_LOWER="arkonexample"
EXAMPLE_PASCAL="ArkonExample"
GITHUB_REPO="https://github.com/Arkonsoft/PS-Example-Module-8.git"

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

# Utility functions
to_lower() {
    echo "$1" | tr '[:upper:]' '[:lower:]'
}

to_pascal() {
    first_char=$(echo "$1" | cut -c1 | tr '[:lower:]' '[:upper:]')
    rest_chars=$(echo "$1" | cut -c2-)
    echo "${first_char}${rest_chars}"
}

# Validation functions
validate_input() {
    if [ $# -lt 1 ]; then
        log_error "Error: Module name is required"
        echo "Usage: $0 <module_name>"
        exit 1
    fi

    # Check if module name contains only valid characters
    if ! echo "$1" | grep -q '^[a-zA-Z][a-zA-Z0-9]*$'; then
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
    search_text=$1
    replace_text=$2
    
    find . -type f -not -path "*/\.*" -not -path "*/vendor/*" | while read file; do
        if [ -s "$file" ]; then
            log_warning "Processing file: $(basename "$file")"
            
            if grep -q "$search_text" "$file"; then
                sed -i "s/$search_text/$replace_text/g" "$file"
                log_success "  Changes made to file"
            else
                echo "  No changes needed"
            fi
        fi
    done
}

rename_module_files() {
    log_info "Renaming files..."
    
    find . -type f -not -path "*/\.*" -not -path "*/vendor/*" | while read file; do
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
    done
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

delete_readme() {
    log_info "Deleting README.md..."
    if [ -f "README.md" ]; then
        rm "README.md"
        log_success "README.md deleted successfully"
    else
        log_warning "README.md not found"
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
    delete_readme
    install_module_dependencies

    # Return to original location
    cd "$original_location"

    log_info "Module configuration completed successfully"
    log_warning "Module location: $target_path"
}

# Execute main function
main "$@"
