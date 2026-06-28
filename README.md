# rclone-systemd-sync

A lightweight, systemd-based automation setup for `rclone bisync` designed to run seamlessly on Linux desktop environments (including Hyprland, Niri, Caelestra, etc.).

---

## Comparison with Alternative Solutions

If you need a more complex, daemon-based manager supporting multiple sync directories and a GTK-based tray icon, check out [rclone-bisync-manager](https://github.com/Gunther-Schulz/rclone-bisync-manager).

Here is a quick comparison to help you choose the right tool for your setup:

| Feature | `rclone-systemd-sync` (This Project) | `rclone-bisync-manager` |
| :--- | :--- | :--- |
| **Architecture** | **Lightweight Bash scripts** powered by systemd user timers. | **Python 3.12+ daemon** running continuously in background. |
| **Dependencies** | Zero external runtimes (uses standard systemd/coreutils). | Requires Python environment and pip package installations. |
| **Job Management** | Single target folder configured via a simple `.env`. | **Multiple independent jobs** with different remote directories. |
| **Waybar Integration**| **Native custom JSON module** with interactive click bindings. | Relies on generic GTK System Tray (`tray` module). |
| **Shutdown Protection** | **Guaranteed**: system-level systemd service blocks shutdown. | Standard daemon (does not block poweroff/reboot natively). |
| **Runtime Overhead** | Zero daemon overhead (only runs when timer triggers). | Runs a persistent Python process in the background. |
| **Privileges** | Toggling sync via bar requires **no sudo/pkexec password**. | Requires config permissions to reload daemon parameters. |

### When to use which?

* **Choose `rclone-systemd-sync` if**:
  - You only want to sync a single main directory (e.g. `SyncArea`).
  - You are using Wayland compositors (Hyprland, Niri) and want a clean, minimalist status bar widget on Waybar without running a GTK tray app.
  - You want to ensure your machine never powers off before synchronizing files (shutdown sync).
  
* **Choose `rclone-bisync-manager` if**:
  - You need to sync multiple folders with different schedules (e.g., Photos daily, Work files hourly).
  - You prefer a standard system tray icon with graphical menu controls.

---

## Features

RClone is automatically executed in the following scenarios:
1. **On system startup** — Syncs files immediately after boot.
2. **Every 30 minutes** — Periodic background synchronization.
3. **On system shutdown** — Blocks shutdown until synchronization completes, preventing data loss.
4. **Waybar Integration** — Displays status and lets you trigger sync (Left-click) or pause/resume (Right-click) without GUI password prompts. See the [Waybar Guide](waybar).

---

## Installation & Setup (Original Project)

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
