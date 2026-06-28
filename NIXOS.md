# NixOS & Home Manager Configuration

This guide explains how to install and configure the RClone Sync automation on NixOS using a declarative approach, avoiding imperative scripts (`install.sh`).

## 1. Setting up the Configuration

Place your environment configuration at `~/.config/rclone-systemd-sync/.env` (or let Home Manager generate it):

```nix
# If using Home Manager to generate the config file:
xdg.configFile."rclone-systemd-sync/.env".text = ''
  LOCAL_DIR=/home/user/Documents
  REMOTE_NAME=myremote
  REMOTE_PATH=Documents
  LOCAL_BACKUP_DIR=/home/user/.rclone_backup
  REMOTE_BACKUP_DIR=Documents_backup
  LOG_FILE=/home/user/.rclone-systemd-sync.log
'';
```

Make sure the `start_sync.sh` script is placed correctly and is executable. E.g. in `~/.config/rclone-systemd-sync/start_sync.sh`.

## 2. User Services (Home Manager)

Add the following to your `home.nix` to configure the user-level timer and service:

```nix
systemd.user.services.rclone-systemd-sync = {
  Unit = {
    Description = "RClone Synchronization Service";
    DefaultDependencies = "no";
    Before = [ "shutdown.target" ];
    After = [ "network.target" ];
  };
  Service = {
    Type = "oneshot";
    # Point this to wherever you stored start_sync.sh
    ExecStart = "${pkgs.bash}/bin/bash %h/.config/rclone-systemd-sync/start_sync.sh";
  };
};

systemd.user.timers.rclone-systemd-sync = {
  Unit = {
    Description = "Run rclone sync every 30 minutes and at boot";
  };
  Timer = {
    OnBootSec = "1min";
    OnUnitActiveSec = "30min";
    Unit = "rclone-systemd-sync.service";
  };
  Install = {
    WantedBy = [ "timers.target" ];
  };
};
```

## 3. System Shutdown Service (NixOS Configuration)

Add the following to your `configuration.nix` so that sync runs for all users upon system shutdown:

```nix
systemd.services.rclone-systemd-sync-shutdown = {
  description = "User Rclone sync on shutdown";
  defaultDependencies = false;
  before = [ "shutdown.target" ];
  wants = [ "network-online.target" ];
  after = [ "network-online.target" ];
  
  serviceConfig = {
    Type = "oneshot";
    TimeoutStartSec = "5min";
    ExecStart = ''
      ${pkgs.bash}/bin/bash -c '\
      for homedir in /home/*; do \
          if [[ -d "$homedir" ]]; then \
              u=$(basename "$homedir"); \
              if [[ -x "$homedir/.config/rclone-systemd-sync/start_sync.sh" ]]; then \
                  ${pkgs.sudo}/bin/sudo -H -u "$u" "$homedir/.config/rclone-systemd-sync/start_sync.sh" || echo "Sync failed for $u"; \
              fi; \
          fi; \
      done'
    '';
  };
  
  wantedBy = [ "shutdown.target" ];
};
```

## Waybar Integration

The Waybar scripts (`waybar_rclone.sh` and JSONC modules) can be included similarly by placing them in your Waybar configuration through Home Manager. When toggled, it will simply touch or remove `~/.config/rclone-systemd-sync/disabled`.
