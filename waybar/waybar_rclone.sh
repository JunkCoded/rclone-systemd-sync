#!/usr/bin/env bash
set -euo pipefail

UNIT="rclone_sync.service"                 # твой юзер-сервис
TIMER="rclone_sync.timer"                  # твой юзер-таймер
SYS_SHUTDOWN_UNIT="rclone_sync_shutdown.service"  # системный юнит на выключение
WAYBAR_SIG="8"                             # номер сигнала для мгновенного обновления
CFG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/rclone_sync"


esc() {
  sed ':a;N;$!ba;s/\n/\\n/g' | sed 's/"/\\"/g'
}

status_json() {
  local timer_active service_active result exitcode start exit
  timer_active=$(systemctl --user is-active "$TIMER" 2>/dev/null || true)
  service_active=$(systemctl --user is-active "$UNIT" 2>/dev/null || true)
  result=$(systemctl --user show "$UNIT" -p Result --value 2>/dev/null || echo "")
  exitcode=$(systemctl --user show "$UNIT" -p ExecMainStatus --value 2>/dev/null || echo "")
  start=$(systemctl --user show "$UNIT" -p ExecMainStartTimestamp --value 2>/dev/null || echo "")
  exit=$(systemctl --user show "$UNIT" -p ExecMainExitTimestamp --value 2>/dev/null || echo "")

  local state icon
  if [[ -f "$CFG_DIR/disabled" ]]; then
    state="disabled";  icon=""
  elif [[ "$service_active" == "activating" || "$service_active" == "active" ]]; then
    state="syncing";   icon="󰑓"
  elif [[ -n "${result:-}" && "$result" != "success" ]]; then
    state="error";     icon=""
  else
    state="synced";    icon=""
  fi

  local timer_enabled shutdown_state=""
  timer_enabled=$(systemctl --user is-enabled "$TIMER" 2>/dev/null || true)
  shutdown_state="$(systemctl --system is-enabled "$SYS_SHUTDOWN_UNIT" 2>/dev/null || true)/$(systemctl --system is-active "$SYS_SHUTDOWN_UNIT" 2>/dev/null || true)"

  local tooltip
  tooltip=$(cat <<EOF
State: $state
Timer: $timer_enabled/$timer_active
Service: $service_active result=${result:-n/a} code=${exitcode:-n/a}
Start: ${start:-n/a}
Exit: ${exit:-n/a}
Shutdown unit: ${shutdown_state:-n/a}
EOF
)

  printf '{"text":"%s","alt":"%s","tooltip":"%s","class":"%s"}\n' \
    "$icon" "$state" "$(printf '%s' "$tooltip" | esc)" "$state"
}

case "${1:-status}" in
  status) status_json ;;
  sync)
    systemctl --user start "$UNIT" &
    pkill -SIGRTMIN+$WAYBAR_SIG waybar 2>/dev/null || true
    ;;
  toggle-sync)
    if [[ -f "$CFG_DIR/disabled" ]]; then
      rm -f "$CFG_DIR/disabled"
    else
      mkdir -p "$CFG_DIR"
      touch "$CFG_DIR/disabled"
    fi
    pkill -SIGRTMIN+$WAYBAR_SIG waybar 2>/dev/null || true
    ;;
  *)
    echo "Usage: $0 [status|sync|toggle-sync]" >&2
    exit 1
    ;;
esac

