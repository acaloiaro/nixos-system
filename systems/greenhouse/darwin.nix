{
  pkgs,
  ...
}:
{
  security.pam.services.sudo_local.touchIdAuth = true;
  system = {
    keyboard.enableKeyMapping = true;
    keyboard.remapCapsLockToControl = true;
    primaryUser = "adriano.caloiaro";
  };
  users = {
    knownUsers = [ "adriano.caloiaro" ];
    users."adriano.caloiaro" = {
      uid = 502;
      shell = pkgs.fish;
      home = "/Users/adriano.caloiaro";
    };
  };
  environment = {
    etc = {
      "dict.conf".text = "server dict.org";
    };
    variables = {
      HOMEBREW_NO_ANALYTICS = "1";
      NH_FLAKE = "/Users/adriano.caloiaro/proj/nixos-system";
    };
    systemPackages = with pkgs; [
      gnupg
      gopass
      helix
      nh
      ripgrep
      qrtool
      vim
    ];
  };
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };
    brews = [
      "coreutils"
      {
        name = "pulseaudio";
        restart_service = "changed";
        start_service = true;
      }
    ];
    # Update these applicatons manually.
    # As brew would update them by unninstalling and installing the newest
    # version, it could lead to data loss.
    casks = [
      "beeper"
      "vlc"
      "spotify"
    ];
    taps = [
    ];
    masApps = {
      # Tailscale = 1475387142; # App Store URL id (keep for example purposes)
    };
  };
  services = {
    aerospace = {
      enable = true;
      settings = {
        enable-normalization-flatten-containers = false;
        enable-normalization-opposite-orientation-for-nested-containers = false;
        gaps =
          let
            dim = 0;
            dims = {
              left = dim;
              bottom = dim;
              top = dim;
              right = dim;
            };
          in
          {
            outer = dims;
            # inner = dims;
          };

        mode.main.binding = {
          alt-slash = "layout tiles horizontal vertical";
          alt-comma = "layout accordion horizontal vertical";

          # See: https://nikitabobko.github.io/AeroSpace/commands#focus
          alt-h = "focus left";
          alt-j = "focus down";
          alt-k = "focus up";
          alt-l = "focus right";

          # See: https://nikitabobko.github.io/AeroSpace/commands#move
          alt-shift-h = "move left";
          alt-shift-j = "move down";
          alt-shift-k = "move up";
          alt-shift-l = "move right";

          # See: https://nikitabobko.github.io/AeroSpace/commands#resize
          alt-minus = "resize smart -50";
          alt-equal = "resize smart +50";

          # See: https://nikitabobko.github.io/AeroSpace/commands#workspace
          alt-1 = "workspace 1";
          alt-2 = "workspace 2";
          alt-3 = "workspace 3";
          alt-4 = "workspace 4";
          alt-5 = "workspace 5";
          alt-6 = "workspace 6";
          alt-7 = "workspace 7";
          alt-8 = "workspace 8";
          alt-9 = "workspace 9";

          # See: https://nikitabobko.github.io/AeroSpace/commands#move-node-to-workspace
          alt-shift-1 = "move-node-to-workspace 1";
          alt-shift-2 = "move-node-to-workspace 2";
          alt-shift-3 = "move-node-to-workspace 3";
          alt-shift-4 = "move-node-to-workspace 4";
          alt-shift-5 = "move-node-to-workspace 5";
          alt-shift-6 = "move-node-to-workspace 6";
          alt-shift-7 = "move-node-to-workspace 7";
          alt-shift-8 = "move-node-to-workspace 8";
          alt-shift-9 = "move-node-to-workspace 9";
        };
      };
    };
  };

  # Necessary for using flakes on this
  nix.settings.experimental-features = "nix-command flakes";

  # Enable alternative shell support in nix-darwin.
  programs = {
    fish.enable = true;
    # starship = {
    #   enable = true;
    #   enableFishIntegration = true;
    # };
  };

  # Set Git commit hash for darwin-version.
  configurationRevision = null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  stateVersion = 6;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
}
