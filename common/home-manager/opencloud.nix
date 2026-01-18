{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.my.opencloud;
in {
  imports = [
    ../services/tailscale-serve.nix
  ];

  options.my.opencloud = {
    enable = mkEnableOption "Enable Opencloud Server";
    hostname = mkOption {
      type = types.str;
      description = "The hostname for the Opencloud server.";
    };
    serve = mkOption {
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

  config = mkIf cfg.enable {
    services.opencloud = {
      enable = true;
      address = "127.0.0.1";
      port = 9200;
      stateDir = "/opencloud";
      environment = {
        OC_INSECURE = "true";
        OC_URL = "https://${cfg.hostname}";
        OC_LOG_LEVEL = "info";
      };
    };

    # Use the new tailscale-serve module
    services.tailscale-serve = {
      enable = true;
      services.opencloud = {
        mappings = cfg.serve;
      };
    };
  };
}
