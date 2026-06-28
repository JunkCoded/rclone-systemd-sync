# RClone Automation System

An automated, robust synchronization setup using `rclone bisync`. Designed for desktop environments to keep your directories in sync seamlessly.

## Features

RClone is automatically executed in the following scenarios:
1. **On system startup** — Syncs files immediately after boot.
2. **Every 30 minutes** — Periodic background synchronization.
3. **On system shutdown** — Blocks shutdown until synchronization completes, preventing data loss.
4. **Waybar Integration** — Displays status and lets you trigger sync (Left-click) or pause/resume (Right-click) without GUI password prompts. See the [Waybar Guide](waybar).

---

## Installation & Setup

### Standard Linux (systemd)

1. Clone the repository and run the interactive installer:
   ```bash
   git clone https://github.com/JunkCoded/rclone_sync.git
   cd rclone_sync
   chmod +x install.sh
   ./install.sh
   ```
2. The setup will guide you through setting up variables and save them to `~/.config/rclone_sync/.env`.

To remove the automation:
```bash
chmod +x uninstall.sh
./uninstall.sh
```

### NixOS & Home Manager

For a declarative, non-imperative configuration (systemd timers, shutdown hooks), please refer to the [NixOS Guide](NIXOS.md).

---

## Configuration

All files are stored in the standard XDG path:
* **Configuration file**: `~/.config/rclone_sync/.env`
* **Disable flag**: `~/.config/rclone_sync/disabled` (creating this file pauses all automated syncs instantly).

---

## Notes

This system was originally developed with AI assistance. Pull requests, suggestions, or improvements are always welcome!
