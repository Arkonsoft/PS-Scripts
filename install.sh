#!/bin/bash

# PrestaShop Scripts Installer
# This script downloads and installs PrestaShop development scripts

set -euo pipefail

# Simple text-based output without colors

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

# Configuration
ARKONSOFT_DIR="$HOME/.arkonsoft"
SCRIPTS_DIR="$ARKONSOFT_DIR/scripts"
REPO_URL="https://raw.githubusercontent.com/Arkonsoft/ps-scripts/main"

# Function to detect shell profile file
detect_profile() {
    if [ -n "${ZSH_VERSION:-}" ]; then
        echo "$HOME/.zshrc"
    elif [ -n "${BASH_VERSION:-}" ]; then
        if [ -f "$HOME/.bashrc" ]; then
            echo "$HOME/.bashrc"
        elif [ -f "$HOME/.bash_profile" ]; then
            echo "$HOME/.bash_profile"
        else
            echo "$HOME/.bashrc"
        fi
    else
        echo "$HOME/.profile"
    fi
}

# Function to check if profile already contains our configuration
profile_contains_config() {
    local profile_file="$1"
    if [ -f "$profile_file" ]; then
        grep -q "ARKONSOFT_DIR" "$profile_file" 2>/dev/null || return 1
    else
        return 1
    fi
}

# Function to add configuration to profile
add_to_profile() {
    local profile_file="$1"
    local config_lines="
# PrestaShop Scripts Configuration
export ARKONSOFT_DIR=\"\$HOME/.arkonsoft\"
[ -s \"\$ARKONSOFT_DIR/scripts/loader.sh\" ] && \. \"\$ARKONSOFT_DIR/scripts/loader.sh\" # To ładuje skrypty PrestaShop
export PATH=\"\$ARKONSOFT_DIR/bin:\$PATH\" # Add PrestaShop scripts to PATH"

    if [ -f "$profile_file" ]; then
        echo "$config_lines" >> "$profile_file"
    else
        echo "$config_lines" > "$profile_file"
    fi
}

# Main installation function
install_scripts() {
    log_info "Installing PrestaShop Scripts..."
    
    # Create directory structure
    log_info "Creating directory: $ARKONSOFT_DIR"
    mkdir -p "$SCRIPTS_DIR"
    
    # Download scripts
    log_info "Downloading scripts from repository..."
    for script in check.sh create.sh docker-create.sh index.sh license.sh htaccess.sh loader.sh; do
        log_info "Downloading $script..."
        if curl -s -f -o "$SCRIPTS_DIR/$script" "$REPO_URL/scripts/$script"; then
            chmod +x "$SCRIPTS_DIR/$script"
            log_success "Downloaded and made executable: $script"
        else
            log_error "Failed to download: $script"
            exit 1
        fi
    done
    
    # Detect and configure shell profile
    profile_file=$(detect_profile)
    log_info "Detected profile file: $profile_file"
    
    if profile_contains_config "$profile_file"; then
        log_warning "Configuration already exists in $profile_file"
    else
        log_info "Adding configuration to $profile_file"
        add_to_profile "$profile_file"
        log_success "Configuration added to $profile_file"
    fi
    
    log_success "Installation completed successfully!"
    log_info ""
    log_info "To start using the scripts, either:"
    log_info "1. Restart your terminal, or"
    log_info "2. Run: source $profile_file"
    log_info ""
    log_info "Available commands after installation:"
    log_info "  ps:module-check    # Check PrestaShop module installation"
    log_info "  ps:module-create   # Create new PrestaShop module"
    log_info "  ps:docker-create   # Setup Docker configuration for PrestaShop"
    log_info "  ps:module-license  # Check licenses in files"
    log_info "  ps:module-index    # Create index.php files in subdirectories"
    log_info "  ps:module-htaccess # Create missing .htaccess files for module and log directories"
}

# Always use GitHub installation mode for consistency
# This ensures the same behavior regardless of current directory or installation method
install_scripts
