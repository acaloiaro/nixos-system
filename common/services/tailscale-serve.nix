{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.tailscale-serve;
in {
  options.services.tailscale-serve = {
    enable = mkEnableOption "Enable Tailscale serve functionality";
    services = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          mappings = mkOption {
            type = types.attrsOf (types.submodule {
              options = {
                port = mkOption {
                  type = types.port;
                  description = "The public port to serve: e.g. 80";
                };
                backend = mkOption {
                  type = types.str;
                  description = "The local address to serve: e.g. localhost:9200";
                };
                insecure = mkOption {
                  type = types.bool;
                  default = false;
                  description = "Connect to the backend insecurely via https (self-signed certs ok). When false (default), connects via http.";
                };
              };
            });
            default = {};
            description = "A set of public port to local address mappings to serve.";
          };
        };
      });
      default = {};
      description = "Named Tailscale serve configurations";
    };
  };

  config = mkIf cfg.enable {
    systemd.services =
      mapAttrs' (
        name: serviceCfg:
          nameValuePair "tailscale-serve-${name}" {
            description = "Tailscale serve for ${name}";
            after = ["tailscaled.service" "network-online.target"];
            wants = ["network-online.target"];
            wantedBy = ["multi-user.target"];
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
              ExecStart = let
                servers =
                  mapAttrsToList (
                    mappingName: mappingCfg: let
                      protocol =
                        if mappingCfg.insecure
                        then "https+insecure://"
                        else "http://";
                    in "${toString mappingCfg.port} ${protocol}${mappingCfg.backend}"
                  )
                  serviceCfg.mappings;
              in
                pkgs.writeShellScript "tailscale-serve-${name}" ''
                  ${pkgs.tailscale}/bin/tailscale serve --bg --https ${builtins.concatStringsSep " " servers}
                '';
              ExecStop = "${pkgs.tailscale}/bin/tailscale serve --reset";
              Restart = "on-failure";
              RestartSec = "5s";
            };
          }
      )
      cfg.services;
  };
}
