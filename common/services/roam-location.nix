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
      };
      serviceConfig = {
        ExecStart = "${roam-location}/bin/roam-location";
        Restart = "on-failure";
        RestartSec = "5s";
        DynamicUser = true;
      };
    };
    networking.firewall.allowedTCPPorts = [ 22495 ];
  };
}
