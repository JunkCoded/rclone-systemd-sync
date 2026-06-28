#!/usr/bin/env bash
set -euo pipefail

# === CONFIGURATION ===
ENV_FILE=".env"
EXAMPLE_FILE="example.env"
USER_SERVICE="rclone_sync.service"
USER_TIMER="rclone_sync.timer"
SHUTDOWN_SERVICE="rclone_sync_shutdown.service"
START_SCRIPT="start_sync.sh"
USER_SYSTEMD_DIR="$HOME/.config/systemd/user"
ROOT_SYSTEMD_DIR="/etc/systemd/system"
CFG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/rclone_sync"

# === FUNCTION DEFINITIONS ===

# Step 1: Configure environment variables
setup_env() {
    if [[ ! -f "$EXAMPLE_FILE" ]]; then
        echo "Error: $EXAMPLE_FILE not found!"
        exit 1
    fi

    declare -A env_values
    declare -a keys_order
    echo "--- Configuring environment variables ---"

    # Read example.env and resolve env variables (e.g. $USER)
    while IFS='=' read -r key value; do
        [[ "$key" =~ ^#.*$ || -z "$key" ]] && continue
        # Strip outer quotes
        value="${value%\"}"
        value="${value#\"}"
        # Evaluate variable expansion in the default value
        eval "value=\"$value\""
        env_values["$key"]="$value"
        keys_order+=("$key")
    done < "$EXAMPLE_FILE"

    # Ask user for each variable in order
    for key in "${keys_order[@]}"; do
        current="${env_values[$key]}"
        read -rp "Enter value for $key [$current]: " input
        if [[ -n "$input" ]]; then
            env_values[$key]="$input"
        fi
    done

    # Write to .env
    {
        for key in "${keys_order[@]}"; do
            echo "$key=\"${env_values[$key]}\""
        done
    } > "$ENV_FILE"

    echo "Environment variables saved to $ENV_FILE"
}

# Step 2: Copy service and script files
copy_files() {
    echo "--- Copying service and script files ---"
    mkdir -p "$USER_SYSTEMD_DIR"
    mkdir -p "$CFG_DIR"

    cp -v "$USER_SERVICE" "$USER_SYSTEMD_DIR/"
    cp -v "$USER_TIMER" "$USER_SYSTEMD_DIR/"
    sudo cp -v "$SHUTDOWN_SERVICE" "$ROOT_SYSTEMD_DIR/"
    cp -v "$START_SCRIPT" "$CFG_DIR/"
    cp -v "$ENV_FILE" "$CFG_DIR/"

    chmod +x "$CFG_DIR/$START_SCRIPT"
}

# Step 3: Reload systemd
reload_systemd() {
    echo "--- Reloading systemd daemons ---"
    systemctl --user daemon-reload
    sudo systemctl daemon-reload
}

# Step 4: Enable and start services
enable_services() {
    echo "--- Enabling and starting user services ---"
    systemctl --user enable --now "$USER_TIMER"

    echo "--- Enabling shutdown service ---"
    sudo systemctl enable "$SHUTDOWN_SERVICE"

    echo "--- Start first sync (with resync) ---"
    bash $CFG_DIR/$START_SCRIPT resync
}

# === MAIN EXECUTION ===
echo "=== Rclone Sync Full Setup ==="
setup_env
copy_files
reload_systemd
enable_services

echo "=== Setup completed successfully! ==="
echo "User timer and service are active."
echo "Shutdown sync service is enabled."
echo "You can remove this folder."
