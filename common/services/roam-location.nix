{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.my.services.roam-location;

  roam-location = pkgs.buildGoModule {
    name = "roam-location";
    src = inputs.roam-location;
    vendorHash = null;
  };
in {
  options.my.services.roam-location = {
    enable = mkEnableOption "roam-location Starlink GPS location service";
    starlinkHost = mkOption {
      type = types.str;
      default = "192.168.100.1:9200";
      description = "Starlink dish gRPC address";
    };
    pollIntervalSeconds = mkOption {
      type = types.int;
      default = 30;
      description = "How often to poll the Starlink dish for location, in seconds";
    };
    webdav = {
      url = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "WebDAV URL to append location snapshots to";
      };
      user = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "WebDAV username";
      };
      passwordFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = "Path to file containing the WebDAV password";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.roam-location-funnel = {
      description = "Tailscale Funnel for roam-location";
      after = ["tailscaled.service" "roam-location.service"];
      wants = ["tailscaled.service" "roam-location.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "roam-location-funnel-start" ''
          ${pkgs.tailscale}/bin/tailscale funnel --bg --https=443 http://localhost:${toString 22495}
        '';
        ExecStop = pkgs.writeShellScript "roam-location-funnel-stop" ''
          ${pkgs.tailscale}/bin/tailscale funnel --https=443 off
          ${pkgs.tailscale}/bin/tailscale serve --https=443 off
        '';
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };

    systemd.services.roam-location = {
      description = "roam-location Starlink GPS location service";
      after = ["network-online.target" "tailscaled.service"];
      wants = ["network-online.target"];
      wantedBy = ["multi-user.target"];
      environment = {
        STARLINK_HOST = cfg.starlinkHost;
        POLL_INTERVAL_SECONDS = toString cfg.pollIntervalSeconds;
      } // lib.optionalAttrs (cfg.webdav.url != null) {
        WEBDAV_URL = cfg.webdav.url;
      } // lib.optionalAttrs (cfg.webdav.user != null) {
        WEBDAV_USER = cfg.webdav.user;
      };
      serviceConfig = {
        ExecStart = if cfg.webdav.passwordFile != null
          then pkgs.writeShellScript "roam-location-start" ''
            export WEBDAV_PASSWORD=$(< "$CREDENTIALS_DIRECTORY/webdav_password")
            exec ${roam-location}/bin/roam-location
          ''
          else "${roam-location}/bin/roam-location";
        Restart = "on-failure";
        RestartSec = "5s";
        DynamicUser = true;
      } // lib.optionalAttrs (cfg.webdav.passwordFile != null) {
        LoadCredential = "webdav_password:${cfg.webdav.passwordFile}";
      };
    };
    networking.firewall.allowedTCPPorts = [ 22495 ];
  };
}
