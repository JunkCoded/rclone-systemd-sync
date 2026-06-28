# Waybar Integration for RClone Automation System

This guide details how to integrate the RClone Automation System with Waybar, providing a custom module to display and control the synchronization status in your HyDE Waybar setup.

## Overview

The Waybar module visually represents the RClone synchronization status with the following states:

- **Synced**: Indicates the synchronization timer is running normally.
- **Synchronizing**: Shown during active synchronization.
- **Error**: Displayed if the last synchronization attempt failed.
- **Disabled**: Indicates the synchronization timer and shutdown service are turned off.

### Interactive Features

- **Left-click**: Initiates a manual synchronization immediately.
- **Right-click**: Toggles the synchronization timer and shutdown service on or off.

### Visual Feedback

- **Color Coding**:
  - Blue: Synchronizing state.
  - Red: Error state.
  - Gray: Disabled state.
- **Animations**: A subtle animation (e.g., pulsing icon) during the synchronizing state for enhanced visual feedback.

## Installation

Follow these steps to set up the Waybar module for RClone synchronization:

### Prerequisites

- Ensure RClone Sync is installed and configured.
- Verify that Waybar is set up in your HyDE environment.
- Have a working `~/.config/waybar` configuration directory.

### Step-by-Step Setup

1. **Copy the Waybar Module Configuration**

   Copy the provided Waybar module configuration to your Waybar modules directory:

   ```bash
   mkdir -p ~/.config/waybar/modules
   cp custom-rclone-systemd-sync.jsonc ~/.config/waybar/modules/
   ```

   The `custom-rclone-systemd-sync.jsonc` file defines the module's behavior and appearance.

2. **Copy the Waybar Script**

   Copy the RClone Waybar script to a dedicated directory and make it executable:

   ```bash
   mkdir -p ~/.config/rclone-systemd-sync
   cp waybar_rclone.sh ~/.config/rclone-systemd-sync/
   chmod +x ~/.config/rclone-systemd-sync/waybar_rclone.sh
   ```

   The `waybar_rclone.sh` script handles the synchronization status logic and click actions.

3. **Update Waybar Layout**

   Copy your config as layout and add the RClone module to your Waybar configuration file (`~/.config/waybar/config.jsonc`):

   ```bash
   cd ~/.config/waybar
   cp config.jsonc layouts/rclone-systemd-sync.jsonc
   nano layouts/rclone-systemd-sync.jsonc
   ```

   Add the `custom/rclone-systemd-sync` module to your desired Waybar group. For example, to add it to the `group/pill#right2` group (commonly used for status icons like battery), include:

   ```json
   {
     "modules-right": [
       "group/pill#right2",
       ...
     ],
     ...
     "group/pill#right2": {
       "modules": [
         "custom/rclone-systemd-sync",
         "battery",
         ...
       ]
     }
   }
   ```

   Save and exit the editor.

   (Example file of layout in waybar/example_layout.jsonc)

4. **Apply Custom Styling**

   Append the provided CSS styles to your Waybar user stylesheet for consistent visuals:

   ```bash
   cat user-style.css >> ~/.config/waybar/user-style.css
   ```

5. **Restart Waybar**

   Reload Waybar to apply the changes and select layout:

   ```bash
   hyde-shell waybar -u
   hyde-shell waybat -L
   ```

   The RClone synchronization status icon will now appear in your Waybar, reflecting the current state and responding to click actions.

## Troubleshooting

- **Module Not Visible**: Ensure the `custom/rclone-systemd-sync` module is correctly added to your `config.jsonc` and that the paths for `custom-rclone-systemd-sync.jsonc` and `waybar_rclone.sh` are correct.
- **Script Not Executable**: Verify that `waybar_rclone.sh` has executable permissions (`chmod +x ~/.config/rclone-systemd-sync/waybar_rclone.sh`).
- **Styling Issues**: Check that the `user-style.css` content is correctly appended to `~/.config/waybar/user-style.css` and that there are no conflicting CSS rules.

## Notes

- The module assumes the `waybar_rclone.sh` script is correctly configured to interface with your RClone setup.
- For advanced customization, modify `custom-rclone-systemd-sync.jsonc` to adjust the module's appearance or behavior.
- If you encounter issues, check the Waybar logs (`waybar --log-level debug`) or the script's output for errors.

This integration enhances your workflow by providing real-time feedback and control over RClone synchronization directly from your Waybar interface.