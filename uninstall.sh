#!/usr/bin/env bash
set -euo pipefail

CFG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/rclone-systemd-sync"
USER_SYSTEMD_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"

sudo rm -f /etc/systemd/system/rclone-systemd-sync-shutdown.service
rm -rf "$CFG_DIR"
rm -f "$USER_SYSTEMD_DIR"/rclone-systemd-sync.*