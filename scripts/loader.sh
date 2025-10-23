#!/bin/bash

# PrestaShop Scripts Loader
# This file creates wrapper scripts for all PrestaShop scripts

ARKONSOFT_DIR="$HOME/.arkonsoft"
SCRIPTS_DIR="$ARKONSOFT_DIR/scripts"
BIN_DIR="$ARKONSOFT_DIR/bin"

# Check if already loaded to avoid re-running
if [ -n "$PS_SCRIPTS_LOADED" ]; then
    return 0
fi

# Create bin directory if it doesn't exist
mkdir -p "$BIN_DIR"

# Create wrapper scripts
create_wrapper() {
    local script_name="$1"
    local target_script="$2"
    local wrapper_path="$BIN_DIR/$script_name"
    
    # Only create if it doesn't exist or is older than the source script
    if [ ! -f "$wrapper_path" ] || [ "$SCRIPTS_DIR/$target_script" -nt "$wrapper_path" ]; then
        cat > "$wrapper_path" << EOF
#!/bin/bash
if [ -f "$SCRIPTS_DIR/$target_script" ]; then
    "$SCRIPTS_DIR/$target_script" "\$@"
else
    echo "Error: $target_script not found in $SCRIPTS_DIR"
    exit 1
fi
EOF
        chmod +x "$wrapper_path"
    fi
}

# Create wrapper scripts for each command
create_wrapper "ps:module-check" "check.sh"
create_wrapper "ps:module-create" "create.sh"
create_wrapper "ps:docker-create" "docker-create.sh"
create_wrapper "ps:module-license" "license.sh"
create_wrapper "ps:module-index" "index.sh"

# Add bin directory to PATH if not already present
if [ -d "$BIN_DIR" ] && [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    export PATH="$BIN_DIR:$PATH"
fi

# Mark as loaded
export PS_SCRIPTS_LOADED=1
