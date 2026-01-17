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
    systemd.user.services =
      mapAttrs' (
        name: serviceCfg:
          nameValuePair "tailscale-serve-${name}" {
            description = "Tailscale serve for ${name}";
            after = ["tailscale.service"];
            wantedBy = ["multi-user.target"];
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
              ExecStart = let
                servers = builtins.map (s: "tcp ${toString s.port} ${s.backend}") (builtins.attrValues serviceCfg.mappings);
              in
                pkgs.writeShellScript "tailscale-serve-${name}" ''
                  ${pkgs.tailscale}/bin/tailscale serve --bg ${builtins.concatStringsSep " " servers}
                '';
              ExecStop = "${pkgs.tailscale}/bin/tailscale serve --reset";
            };
          }
      )
      cfg.services;
  };
}
