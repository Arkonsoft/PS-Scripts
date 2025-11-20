#!/bin/bash

# Simple text-based output without colors
set -euo pipefail

# Logging helpers
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

MODULE_PATH="."
MODULE_NAME=$(basename "$PWD")

ROOT_CREATED=0
ROOT_SKIPPED=0
LOG_CREATED=0
LOG_SKIPPED=0

log_info "Ensuring .htaccess files for module: $MODULE_NAME"

create_root_htaccess() {
    local target_file="$MODULE_PATH/.htaccess"

    if [ -f "$target_file" ] && [ -s "$target_file" ]; then
        log_warning "Skipping root .htaccess (already exists): $target_file"
        ROOT_SKIPPED=1
        return
    fi

    cat > "$target_file" <<'EOF'
# Apache 2.2
<IfModule !mod_authz_core.c>
   <Files *.php>
   order allow,deny
   deny from all
   </Files>
</IfModule>

# Apache 2.4
<IfModule mod_authz_core.c>
   <Files *.php>
   Require all denied
   </Files>
</IfModule>
EOF

    log_success "Created root .htaccess: $target_file"
    ROOT_CREATED=1
}

create_log_htaccess() {
    local directory="$1"
    local target_file="$directory/.htaccess"

    if [ -f "$target_file" ] && [ -s "$target_file" ]; then
        log_warning "Skipping log .htaccess (already exists): $target_file"
        LOG_SKIPPED=$((LOG_SKIPPED + 1))
        return
    fi

    cat > "$target_file" <<'EOF'
# Apache 2.2
<IfModule !mod_authz_core.c>
   <Files *.php>
   order allow,deny
   deny from all
   </Files>
   <Files *.log>
   order allow,deny
   deny from all
   </Files>
</IfModule>

# Apache 2.4
<IfModule mod_authz_core.c>
   <Files *.php>
   Require all denied
   </Files>
   <Files *.log>
   Require all denied
   </Files>
</IfModule>
EOF

    log_success "Created log .htaccess: $target_file"
    LOG_CREATED=$((LOG_CREATED + 1))
}

create_root_htaccess

log_info "Searching for log/logs directories..."
LOG_DIR_FOUND=0

while IFS= read -r -d '' log_dir; do
    LOG_DIR_FOUND=1
    create_log_htaccess "$log_dir"
done < <(find "$MODULE_PATH" -type d \( -name "vendor" -o -name "node_modules" -o -name ".git" -o -name ".github" -o -name "tests" -o -name "translations" -o -name "override" \) -prune -o -type d \( -name "log" -o -name "logs" \) -print0)

if [ "$LOG_DIR_FOUND" -eq 0 ]; then
    log_info "No log or logs directories found."
fi

log_info "Summary:"
if [ "$ROOT_CREATED" -eq 1 ]; then
    log_success "Root .htaccess created."
else
    log_warning "Root .htaccess already existed."
fi

log_info "Log directories: created $LOG_CREATED, skipped $LOG_SKIPPED"

log_success ".htaccess generation completed."
