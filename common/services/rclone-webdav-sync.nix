{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.services.rclone-webdav-sync;
in {
  options.my.services.rclone-webdav-sync = {
    enable = mkEnableOption "rclone webdav sync service";

    sourcePath = mkOption {
      type = types.str;
      default = "/storage";
      description = "Local path to sync from";
    };

    webdav = {
      url = mkOption {
        type = types.str;
        description = "WebDAV URL endpoint";
        example = "https://oc.adriano.fyi/remote.php/dav/files/username/";
      };

      user = mkOption {
        type = types.str;
        description = "WebDAV username";
      };

      passwordFile = mkOption {
        type = types.str;
        description = "Path to file containing the WebDAV password (will be obscured with rclone obscure)";
      };

      vendor = mkOption {
        type = types.str;
        default = "other";
        description = "WebDAV vendor type (nextcloud, owncloud, sharepoint, other)";
      };

      remotePath = mkOption {
        type = types.str;
        default = "";
        description = "Remote path within webdav to sync to (relative to webdav root)";
      };
    };

    interval = mkOption {
      type = types.str;
      default = "daily";
      description = "How often to run the sync (systemd timer calendar spec)";
    };

    rcloneArgs = mkOption {
      type = types.listOf types.str;
      default = ["-v" "--progress"];
      description = "Additional arguments to pass to rclone copy";
    };

    bandwidthLimit = mkOption {
      type = types.nullOr types.str;
      default = "250k";
      description = ''
        Bandwidth limit for rclone (e.g., '10M' for 10 MB/s, '512k' for 512 KB/s).
        Set to null to disable bandwidth limiting entirely.
        Default is 250k (~2 Mbits/s).
      '';
      example = "5M";
    };
  };

  config = mkIf cfg.enable (let
    syncScript = pkgs.writeShellScriptBin "rclone-webdav-sync" ''
      set -euo pipefail

      LOCKFILE="/var/lock/rclone-webdav-sync.lock"

      # Try to acquire lock, exit if already running
      exec 9>"$LOCKFILE"
      if ! ${pkgs.util-linux}/bin/flock --nonblock 9; then
        echo "Another rclone-webdav-sync is already running. Exiting."
        exit 0
      fi

      # Read password from file
      WEBDAV_PASSWORD=$(cat ${escapeShellArg cfg.webdav.passwordFile})

      # Obscure the password for rclone
      OBSCURED_PASSWORD=$(${pkgs.rclone}/bin/rclone obscure "$WEBDAV_PASSWORD")

      # Run rclone sync
      ${pkgs.rclone}/bin/rclone copy \
        ${escapeShellArg cfg.sourcePath} \
        --webdav-vendor ${escapeShellArg cfg.webdav.vendor} \
        --webdav-url ${escapeShellArg cfg.webdav.url} \
        --webdav-user ${escapeShellArg cfg.webdav.user} \
        --webdav-pass "$OBSCURED_PASSWORD" \
        ${optionalString (cfg.bandwidthLimit != null) "--bwlimit ${escapeShellArg cfg.bandwidthLimit}"} \
        ${concatStringsSep " " cfg.rcloneArgs} \
        ":webdav:${cfg.webdav.remotePath}"

      # Lock is automatically released when script exits
    '';
  in {
    # Create the sync script
    environment.systemPackages = [syncScript];

    # Create systemd service
    systemd.services.rclone-webdav-sync = {
      description = "Sync ${cfg.sourcePath} to WebDAV using rclone";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${syncScript}/bin/rclone-webdav-sync";
      };
      path = [pkgs.rclone];
    };

    # Create systemd timer
    systemd.timers.rclone-webdav-sync = {
      description = "Timer for rclone webdav sync";
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = cfg.interval;
        Persistent = true;
      };
    };
  });
}
