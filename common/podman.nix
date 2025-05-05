{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.localServices.podman;
in {
  options.localServices.podman.enable = mkEnableOption "enable podman";
  config = mkIf cfg.enable {
    virtualisation = {
      podman = {
        enable = true;
        # Alias all docker commands to podman
        dockerCompat = false;
        # Required for containers under podman-compose to be able to talk to each other.
        defaultNetwork.settings.dns_enabled = true;
        autoPrune = {
          enable = true;
          dates = "weekly";
          flags = [
            "--filter=until=24h"
            # Don't prune containers flagged 'important'
            "--filter=label!=important"
          ];
        };
      };
    };
    environment.systemPackages = with pkgs; [
      podman-compose
    ];
  };
}
