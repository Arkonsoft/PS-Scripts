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

# Function to detect if the installer was started from a fish shell
# install.sh is interpreted by bash (e.g. `curl ... | bash`), so FISH_VERSION is
# not available - we look at the process that invoked us and at the login shell.
is_fish_shell() {
    if [ -n "${FISH_VERSION:-}" ]; then
        return 0
    fi

    if command -v ps >/dev/null 2>&1; then
        parent_cmd=$(ps -o comm= -p "$PPID" 2>/dev/null | sed 's|^-||')
        if [ "$(basename "$parent_cmd" 2>/dev/null)" = "fish" ]; then
            return 0
        fi
    fi

    if [ "$(basename "${SHELL:-}" 2>/dev/null)" = "fish" ]; then
        return 0
    fi

    return 1
}

# Function to check if fish is the user's login shell
is_fish_login_shell() {
    [ "$(basename "${SHELL:-}" 2>/dev/null)" = "fish" ]
}

# Function to locate the fish configuration file
fish_config_file() {
    echo "${XDG_CONFIG_HOME:-$HOME/.config}/fish/config.fish"
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

# Function to add configuration to fish config
add_to_fish_config() {
    local config_file="$1"
    local config_lines="
# PrestaShop Scripts Configuration
set -gx ARKONSOFT_DIR \"\$HOME/.arkonsoft\"
test -s \"\$ARKONSOFT_DIR/scripts/loader.fish\"; and source \"\$ARKONSOFT_DIR/scripts/loader.fish\" # To ładuje skrypty PrestaShop
# Add PrestaShop scripts to PATH
if not contains \"\$ARKONSOFT_DIR/bin\" \$PATH
    set -gx PATH \"\$ARKONSOFT_DIR/bin\" \$PATH
end"

    mkdir -p "$(dirname "$config_file")"

    if [ -f "$config_file" ]; then
        echo "$config_lines" >> "$config_file"
    else
        echo "$config_lines" > "$config_file"
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
    for script in check.sh check-debug.sh create.sh docker-create.sh index.sh license.sh htaccess.sh loader.sh loader.fish change-name.sh; do
        log_info "Downloading $script..."
        if curl -s -f -o "$SCRIPTS_DIR/$script" "$REPO_URL/scripts/$script"; then
            chmod +x "$SCRIPTS_DIR/$script"
            log_success "Downloaded and made executable: $script"
        else
            log_error "Failed to download: $script"
            exit 1
        fi
    done
    
    # Configure fish if the installer was run from a fish shell
    fish_config=""
    if is_fish_shell; then
        fish_config=$(fish_config_file)
        log_info "Fish shell detected, config file: $fish_config"

        if profile_contains_config "$fish_config"; then
            log_warning "Configuration already exists in $fish_config"
        else
            log_info "Adding configuration to $fish_config"
            add_to_fish_config "$fish_config"
            log_success "Configuration added to $fish_config"
        fi
    fi

    # Detect and configure shell profile
    # Skipped when fish is the login shell - the fish config above covers it
    profile_file=""
    if is_fish_login_shell; then
        log_info "Skipping POSIX shell profile (fish is your login shell)"
    else
        profile_file=$(detect_profile)
        log_info "Detected profile file: $profile_file"

        if profile_contains_config "$profile_file"; then
            log_warning "Configuration already exists in $profile_file"
        else
            log_info "Adding configuration to $profile_file"
            add_to_profile "$profile_file"
            log_success "Configuration added to $profile_file"
        fi
    fi

    log_success "Installation completed successfully!"
    log_info ""
    log_info "To start using the scripts, either:"
    log_info "- Restart your terminal, or"
    if [ -n "$profile_file" ]; then
        log_info "- Run: source $profile_file"
    fi
    if [ -n "$fish_config" ]; then
        log_info "- Run in fish: source $fish_config"
    fi
    log_info ""
    log_info "Available commands after installation:"
    log_info "  ps:module-check    # Check PrestaShop module installation"
    log_info "  ps:module-create   # Create new PrestaShop module"
    log_info "  ps:docker-create   # Setup Docker configuration for PrestaShop"
    log_info "  ps:module-license  # Check licenses in files"
    log_info "  ps:module-index    # Create index.php files in subdirectories"
    log_info "  ps:module-htaccess # Create missing .htaccess files for module and log directories"
    log_info "  ps:module-change-name # Change module name"
}

# Always use GitHub installation mode for consistency
# This ensures the same behavior regardless of current directory or installation method
install_scripts
