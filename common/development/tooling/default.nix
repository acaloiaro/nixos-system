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
  brewBin = "/opt/homebrew/bin";
  brewFileName = ".Brewfile.greenhouse";
  brewFilePath = "$HOME/${brewFileName}";

  # TODO Make configurable/option
  brewTaps = [
    "raggi/ale"
  ];

  # TODO Make configurable/option
  brewBrews = [
    "raggi/ale/openssl-osx-ca"
    "docker"
  ];

  # TODO Make configurable/option
  brewCasks = [
    "1password-cli"
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
  # TODO: Refactor the mkIf; this is goofy
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

        # onFilesChange is the homebrew activation that ensures homebrew packages are installed when Brewfile.greenhouse changes
        configureRequiredSoftware = hm.dag.entryAfter [ "installSystemWideGems" "onFilesChange" ] (
          ''
            export PATH="${
              lib.makeBinPath (
                with pkgs;
                [
                  awscli2
                  ruby
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

            # Enable 1password-cli (Enable integration in 1Password first, Settings -> Developer -> Integrate with 1Password CLI)
            # TODO why isn't /opt/homebrew/bin in the PATH here?
            eval $(/opt/homebrew/bin/op signin)

            # Configure bundler to use Greenhouse's ruby gems repo.
            # This requires you to have added a Github personal access token to 1password under your personal vault named "github-ruby-packages-pat", and the PAT must be in the 'password' field of the entry
            # This also requires you to have logged in with the `gh` CLI: `gh auth login`
            export PAT=$(/opt/homebrew/bin/op item get $(/opt/homebrew/bin/op item list --vault Employee | grep github-ruby-packages-pat | awk '{print $1}') --reveal --fields password)
            export GH_USERNAME=$(${lib.getExe' pkgs.gh "gh"} api user --jq .login)
            bundle config set --global https://rubygems.pkg.github.com/grnhse/ $GH_USERNAME:$PAT
            bundle config --global jobs $(${lib.getExe' pkgs.coreutils "nproc"} --all)''
        );
      };

      packages = with pkgs; [
        asdf-vm
        awscli2
        cmake
        curl
        duckdb
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

      sessionPath = [
        "/usr/bin"
        "${brewBin}"
        "$HOME/go/bin"
      ];
      # These env vars are used by the AWS cli: https://greenhouseio.atlassian.net/wiki/spaces/SE/pages/710803589/2.+Secure+Credentials+Connections#AWS-CLI%2C-AWS-Shim
      sessionVariables = {
        AWS_DEFAULT_PROFILE = "dev.use1";
        AWS_PROFILE = "dev.use1";
        AWS_SDK_LOAD_CONFIG = "true";
        AWS_SESSION_TOKEN_TTL = "24h";
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
          HOMEBREW_BUNDLE_FILE_GLOBAL=${brewFilePath} ${brewBin}/brew bundle install --no-upgrade --force --global
        '';
      };
    };

    programs = {
      git = {
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

      gh = {
        enable = true;

        gitCredentialHelper = {
          enable = true;
        };

        settings = {
          git_protocol = "ssh";
        };
      };
    };
  };
}
