{
  config,
  lib,
  ...
}:
with lib; {
  options.scm = {
    jujutsu = mkOption {
      type = types.submodule {
        options = {
          enable = mkEnableOption "Enable jujutsu scm and configure it";
        };
      };
    };
    git = mkOption {
      type = types.submodule {
        options = {
          enable = mkEnableOption "Enable git scm and configure it";
        };
      };
    };
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
            default = "me@example.com";
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
          description = "Configure scm authorship information, e.g. author, email, and signing keys";
        };
      };
    };
  };
  config = {
    programs = {
      git = mkIf config.scm.git.enable {
        enable = true;
        settings = {
          user = {
            name = config.scm.user.name;
            email = [config.scm.user.email];
          };
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

        signing = {
          key = config.scm.user.gpg-key-id;
          signByDefault = true;
        };
      };

      gh = mkIf config.scm.git.enable {
        enable = true;

        gitCredentialHelper = {
          enable = true;
        };

        settings = {
          git_protocol = "ssh";
        };
      };

      jujutsu = mkIf config.scm.jujutsu.enable {
        enable = true;
        settings = {
          user = {
            name = config.scm.user.name;
            email = config.scm.user.email;
          };
          signing = {
            backend = "ssh";
            key = config.scm.user.ssh-public-key;
          };
          git = {
            sign-on-push = true;
            write-change-id-header = true;
          };
        };
      };
    };
  };
}
