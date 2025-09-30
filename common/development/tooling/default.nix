{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.development.tooling;
in
{
  options.development.tooling = {
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
            description = "GPG key ID of the user (empty if none).";
          };

          ssh-public-key = mkOption {
            type = types.str;
            default = "";
            description = "SSH public key of the user.";
          };
          description = "User-specific tooling configuration.";
        };
      };
    };
  };
  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      userName = cfg.user.name;
      userEmail = cfg.user.email;

      signing = {
        key = mkIf (cfg.user.gpg-key-id != "") cfg.user.gpg-key-id ; 
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
      };
    };
  };
}
