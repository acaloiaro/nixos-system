{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.my.opencloud;
in {
  options.my.opencloud = {
    enable = mkEnableOption "Enable Opencloud Server";
    tailnetHostname = mkOption {
      type = types.str;
      description = "The tailnet hostname for the Opencloud server.";
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
        OC_URL = "https://${cfg.tailnetHostname}";
        OC_LOG_LEVEL = "info";
      };
    };
    services.tailscale.serve = {
      enable = true;
      config = {
        tcp = {
          "80" = {
            http = true;
            local = "127.0.0.1:9200";
          };
        };
      };
    };
  };
}
