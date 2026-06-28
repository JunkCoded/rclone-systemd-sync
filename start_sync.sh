#!/bin/bash

# sync_script.sh
# Runs rclone bisync. Use for manual run or in crontab.
# Usage: bash sync_script.sh [resync/dry]

set -euo pipefail

if ! ping -c1 8.8.8.8 >/dev/null 2>&1; then
  echo "No network available, skipping sync"
  exit 0
fi

source "$HOME/.rclone_sync/.env"

# Base command
COMMAND="rclone bisync \"$LOCAL_DIR\" \"${REMOTE_NAME}:${REMOTE_PATH}\" \
    --backup-dir1 \"$LOCAL_BACKUP_DIR\" \
    --backup-dir2 \"${REMOTE_NAME}:${REMOTE_BACKUP_DIR}\" \
    --conflict-resolve newer \
    --conflict-loser delete \
    --compare size,modtime,checksum \
    --resilient \
    --recover \
    --check-sync true \
    --verbose \
    --log-file \"$LOG_FILE\""

# Add resync if specified
if [ "${1:-}" = "resync" ]; then
    COMMAND="$COMMAND --resync"
fi

if [ "${1:-}" = "dry" ]; then
    COMMAND="$COMMAND --dry-run"
fi

echo "Running sync..."
eval "$COMMAND" || {
    echo "Sync error. Check log: $LOG_FILE"
    exit 1
}
echo "Sync completed."
