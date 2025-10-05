{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.tooling;
  stdenv = pkgs.stdenvNoCC;
  brewFileName = ".Brewfile.greenhouse";
  brewFilePath = "$HOME/${brewFileName}";
  brewTaps = [
    "raggi/ale"
  ];

  brewBrews = [
    "libpq@16"
    "raggi/ale/openssl-osx-ca"
  ];

  brewCasks = [
  ];
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
    home = {
      activation = {
        # configureInternPackageRepoAccess = ''
        #     bundle config set --global https://rubygems.pkg.github.com/grnhse/ <GH USERNAME>:<TOKEN>
        #   '';
        installSystemWideGems = ''
          # tty-prompt is used by the "aws shim": https://greenhouseio.atlassian.net/wiki/spaces/SE/pages/710803589/2.+Secure+Credentials+Connections#AWS-CLI%2C-AWS-Shim
          ${lib.getExe' pkgs.ruby "gem"} install --user-install --no-document tty-prompt 
        '';

        configureRequiredSoftware = ''
          export PATH="${
            lib.makeBinPath (
              with pkgs;
              [
                awscli2
                cmake
                curl
                gh
                imagemagick
                mkcert
                poppler
                pkg-config
                ruby
                unrtf
                wget
              ]
            )
          }:$PATH:/usr/bin"
        ''
        + optionalString stdenv.isDarwin ''
          # Mac only setup
          #
          # The following commands has a non-zero exit code, even if xcode is simply installed already.
          # We're eating errors here, which is not ideal.
          # TODO Find a more elegant solution
          xcode-select --install &2>/dev/null
        ''
        + optionalString stdenv.isLinux ''
          # Linux only setup
        ''
        + ''
          # Make sure installed packages are in our PATH while this script runs
          # Set up AWS
          # ${lib.getExe' pkgs.curl "curl"} -o /tmp/aws-config-shim https://grnhse-vpc-assets.s3.amazonaws.com/installers/aws-config-shim
          # ${lib.getExe' pkgs.ruby "ruby"} /tmp/aws-config-shim
          # bundle config --global jobs $(${lib.getExe' pkgs.coreutils "nproc"} --all)
          echo Please run "bundle config set --global https://rubygems.pkg.github.com/grnhse/ <GITHUB_USERNAME>:<TOKEN>"
        '';
      };

      packages = with pkgs; [
        awscli2
        cmake
        curl
        gh
        imagemagick
        mkcert
        poppler
        pkg-config
        ruby
        unrtf
        wget
        yarn
      ];

      sessionPath = [ "/opt/homebrew/bin" ];
      # These env vars are used by the AWS cli: https://greenhouseio.atlassian.net/wiki/spaces/SE/pages/710803589/2.+Secure+Credentials+Connections#AWS-CLI%2C-AWS-Shim
      sessionVariables = {
        AWS_DEFAULT_PROFILE = "dev.use1";
        AWS_PROFILE = "dev.use1";
        AWS_SDK_LOAD_CONFIG = "true";
        AWS_SESSION_TOKEN_TTL = "24h";
        PATH = "$PATH:$home/.nix-profile/bin:$HOME/go/bin:/usr/bin";
      };

      file."${brewFileName}" = {
        text =
          (concatMapStrings (
            tap:
            ''tap "''
            + tap
            + ''
              "
            ''

          ) brewTaps)
          + (concatMapStrings (
            brew:
            ''brew "''
            + brew
            + ''
              "
            ''

          ) brewBrews)
          + (concatMapStrings (
            cask:
            ''cask "''
            + cask
            + ''
              "
            ''

          ) brewCasks);
        onChange = ''
          HOMEBREW_BUNDLE_FILE_GLOBAL=${brewFilePath} /opt/homebrew/bin/brew bundle install --cleanup --no-upgrade --force --global
        '';
      };
    };

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
  };
}
