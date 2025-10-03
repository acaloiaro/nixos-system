{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.tooling;
in
{
  options.tooling = {
    enable = mkEnableOption "Configure developer tooling";
    user = mkOption {
      type = types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            default = "Firstname Lastname";
            description = "The full name of the user.";
          };

          email = mkOption {
            type = types.str;
            default = "first.last@greenhouse.io";
            description = "The email address of the user.";
          };

          gpg-key-id = mkOption {
            type = types.str;
            default = "";
            description = "GPG key ID for git commit signing";
          };

          ssh-public-key = mkOption {
            type = types.str;
            default = "";
            description = "SSH public key used for jujutsu commit signing";
          };
          description = "User-specific tooling configuration.";
        };
      };
    };
  };
  config = mkIf (isAttrs cfg.user) {
    home.packages = [
      pkgs.yarn
    ];

    programs.git = {
      enable = true;
      userName = cfg.user.name;
      userEmail = cfg.user.email;

      signing = {
        key = mkIf (cfg.user.gpg-key-id != "") cfg.user.gpg-key-id;
        signByDefault = true;
      };

      extraConfig = {
        push = {
          autoSetupRemote = true;
        };
        init = {
          defaultBranch = "main";
        };
        pull = {
          rebase = true;
        };
        blame = {
          ignoreRevsFile = ".git-blame-ignore-revs";
        };
      };
    };

    # https://greenhouseio.atlassian.net/wiki/spaces/SE/pages/710803589/2.+Secure+Credentials+Connections#AWS-CLI%2C-AWS-Shim
    home.sessionVariables = {
      AWS_DEFAULT_PROFILE = "dev.use1";
      AWS_PROFILE = "dev.use1";
      AWS_SDK_LOAD_CONFIG = "true";
      AWS_SESSION_TOKEN_TTL = "24h";
    };
  };
}
