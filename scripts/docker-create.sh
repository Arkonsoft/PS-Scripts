#!/bin/bash

# Simple text-based output without colors

GITHUB_REPO="https://github.com/Arkonsoft/PS-Docker.git"

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


initialize_docker_repository() {
    log_info "Cloning Docker configuration from repository..."
    
    # Create temporary directory for cloning
    temp_dir=$(mktemp -d)
    
    if ! git clone "$GITHUB_REPO" "$temp_dir"; then
        log_error "Error while cloning Docker configuration"
        rm -rf "$temp_dir"
        exit 1
    fi

    log_info "Copying Docker configuration files to current directory..."
    
    # Copy all files from cloned repo to current directory, excluding .git
    cp -r "$temp_dir"/* . 2>/dev/null || true
    # Copy hidden files but exclude .git directory
    for file in "$temp_dir"/.[^.]*; do
        if [[ -e "$file" && "$(basename "$file")" != ".git" ]]; then
            cp -r "$file" . 2>/dev/null || true
        fi
    done
    
    # Clean up temporary directory
    rm -rf "$temp_dir"
    
    log_success "Docker configuration files copied successfully"
}

update_gitignore() {
    local gitignore_file=".gitignore"
    local docker_ignore_line="!/.docker/*"
    
    log_info "Checking .gitignore for Docker configuration..."
    
    # Check if .gitignore exists
    if [[ ! -f "$gitignore_file" ]]; then
        log_info "Creating .gitignore file..."
        touch "$gitignore_file"
    fi
    
    # Check if the Docker ignore line already exists (more flexible search)
    if grep -q "\.docker/\*" "$gitignore_file"; then
        log_info "Docker ignore line already exists in .gitignore"
    else
        log_info "Adding Docker ignore line to .gitignore..."
        echo "$docker_ignore_line" >> "$gitignore_file"
        log_success "Added '$docker_ignore_line' to .gitignore"
    fi
}

show_docker_instructions() {
    log_info "Docker configuration completed successfully!"
    log_warning "Files copied to: $PWD"
    echo ""
    log_info "Next steps:"
    log_warning "1. Create .env file based on .env.example"
    log_warning "2. Review sync.sh file for environment-specific differences"
    log_warning "3. Check database version in docker-compose.yml"
}

# Main execution
main() {
    log_info "Starting Docker configuration setup..."
    log_warning "Target folder: $PWD"
    
    initialize_docker_repository
    update_gitignore
    show_docker_instructions
}

# Execute main function
main "$@"
