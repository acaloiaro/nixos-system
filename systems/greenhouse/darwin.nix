{
  pkgs,
  ...
}: {
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToControl = true;
  security.pam.services.sudo_local.touchIdAuth = true;
  users.knownUsers = ["adriano.caloiaro"];
  users.users."adriano.caloiaro" = {
    uid = 502;
    shell = pkgs.fish;
    home = "/Users/adriano.caloiaro";
  };
  environment.variables = {
    HOMEBREW_NO_ANALYTICS = "1";
    NH_FLAKE = "/Users/adriano.caloiaro/proj/nixos-system";
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
      "pulseaudio"
    ];
    # Update these applicatons manually.
    # As brew would update them by unninstalling and installing the newest
    # version, it could lead to data loss.
    casks = [
      # "docker"
    ];
    taps = [
    ];
    masApps = {
      # Tailscale = 1475387142; # App Store URL id
      # TODO: Add tailscale when I have my adriano.caloiaro@greenhouse.io app store account back
    };
  };
  services = {
    aerospace = {
      enable = true;
      settings = {
        enable-normalization-flatten-containers = false;
        enable-normalization-opposite-orientation-for-nested-containers = false;
        gaps = let
          dim = 0;
          dims = {
            left = dim;
            bottom = dim;
            top = dim;
            right = dim;
          };
        in {
          outer = dims;
          # inner = dims;
        };

        mode.main.binding = {
          # alt-enter =
          #   # osascript
          #   ""
          #     "exec-and-forget osascript -e ""
          #       on is_running(appName)
          #       	tell application "System Events" to (name of processes) contains appName
          #       end is_running

          #       if not is_running("kitty") then
          #       	tell application "kitty" to activate
          #       else
          #       	tell application "System Events" to tell process "kitty"
          #       		click menu item "New OS Window" of menu 1 of menu bar item "Shell" of menu bar 1
          #       	end tell
          #       end if"
          #     ""
          #   "";
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
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    gnupg
    gopass
    helix
    nh
    ripgrep
    qrtool
    vim
  ];

  # Set primary system user
  system.primaryUser = "adriano.caloiaro";

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # Enable alternative shell support in nix-darwin.
  programs = {
    fish.enable = true;
    #   starship = {
    #     enable = true;
    #     enableFishIntegration = true;
    #   };
  };

  # Set Git commit hash for darwin-version.
  system.configurationRevision = null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
}
