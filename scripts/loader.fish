#!/usr/bin/env fish

# PrestaShop Scripts Loader (fish)
# This file creates wrapper scripts for all PrestaShop scripts

function __ps_scripts_create_wrapper --argument-names bin_dir scripts_dir script_name target_script
    set -l wrapper_path "$bin_dir/$script_name"
    set -l target_path "$scripts_dir/$target_script"

    # Only create if it doesn't exist or is older than the source script
    if not test -f "$wrapper_path"; or test "$target_path" -nt "$wrapper_path"
        printf '%s\n' \
            "#!/bin/bash" \
            "if [ -f \"$target_path\" ]; then" \
            "    \"$target_path\" \"\$@\"" \
            "else" \
            "    echo \"Error: $target_script not found in $scripts_dir\"" \
            "    exit 1" \
            "fi" > "$wrapper_path"
        chmod +x "$wrapper_path"
    end
end

# Check if already loaded to avoid re-running
if not set -q PS_SCRIPTS_LOADED
    set -l arkonsoft_dir "$HOME/.arkonsoft"
    set -l scripts_dir "$arkonsoft_dir/scripts"
    set -l bin_dir "$arkonsoft_dir/bin"

    # Create bin directory if it doesn't exist
    mkdir -p "$bin_dir"

    # Create wrapper scripts for each command
    __ps_scripts_create_wrapper "$bin_dir" "$scripts_dir" "ps:module-check" "check.sh"
    __ps_scripts_create_wrapper "$bin_dir" "$scripts_dir" "ps:check-debug" "check-debug.sh"
    __ps_scripts_create_wrapper "$bin_dir" "$scripts_dir" "ps:module-create" "create.sh"
    __ps_scripts_create_wrapper "$bin_dir" "$scripts_dir" "ps:docker-create" "docker-create.sh"
    __ps_scripts_create_wrapper "$bin_dir" "$scripts_dir" "ps:module-license" "license.sh"
    __ps_scripts_create_wrapper "$bin_dir" "$scripts_dir" "ps:module-index" "index.sh"
    __ps_scripts_create_wrapper "$bin_dir" "$scripts_dir" "ps:module-htaccess" "htaccess.sh"
    __ps_scripts_create_wrapper "$bin_dir" "$scripts_dir" "ps:module-change-name" "change-name.sh"

    # Add bin directory to PATH if not already present
    if test -d "$bin_dir"; and not contains "$bin_dir" $PATH
        set -gx PATH "$bin_dir" $PATH
    end

    # Mark as loaded
    set -gx PS_SCRIPTS_LOADED 1
end

functions -e __ps_scripts_create_wrapper
