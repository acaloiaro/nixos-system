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
    s3 = {
      endpoint = mkOption {
        type = types.str;
        description = "S3-compatible endpoint URL (e.g. https://s3.us-east-005.backblazeb2.com).";
      };
      region = mkOption {
        type = types.str;
        description = "S3 region (e.g. us-east-005).";
      };
      bucket = mkOption {
        type = types.str;
        description = "S3 bucket name.";
      };
      credentialsFile = mkOption {
        type = types.path;
        description = "Path to file containing STORAGE_USERS_DECOMPOSEDS3_ACCESS_KEY and STORAGE_USERS_DECOMPOSEDS3_SECRET_KEY.";
      };
    };
  };

  config = mkIf cfg.enable {
    services.opencloud = {
      enable = true;
      address = "127.0.0.1";
      port = 9200;
      stateDir = "/var/lib/opencloud";
      environment = {
        OC_INSECURE = "true";
        OC_URL = "https://${cfg.hostname}";
        OC_LOG_LEVEL = "info";
        STORAGE_USERS_DRIVER = "decomposeds3";
        STORAGE_USERS_DECOMPOSEDS3_ENDPOINT = cfg.s3.endpoint;
        STORAGE_USERS_DECOMPOSEDS3_REGION = cfg.s3.region;
        STORAGE_USERS_DECOMPOSEDS3_BUCKET = cfg.s3.bucket;
      };
    };

    systemd.services.opencloud.serviceConfig.EnvironmentFile = cfg.s3.credentialsFile;

    # Use the new tailscale-serve module
    services.tailscale-serve = {
      enable = true;
      services.opencloud = {
        mappings = {
          http = {
            port = 9200;
            backend = "localhost:9200";
            insecure = true;
          };
        };
      };
    };
  };
}
