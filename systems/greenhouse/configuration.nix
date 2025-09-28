{
  pkgs,
  ...
}:
{
  imports = [
    ../../common/aerospace.nix
  ];
  config = {
    aerospace.enable = true;
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
        "dash"
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
    nix = {
      settings.experimental-features = "nix-command flakes";
    };
    nixpkgs.hostPlatform = "aarch64-darwin";
    programs = {
      fish.enable = true;
    };
    security.pam.services.sudo_local.touchIdAuth = true;
    services = {
      defaultBrowser = {
        enable = true;
        browser = "safari"; # or "chrome", "safari", "dia", etc.
      };
    };
    system = {
      keyboard.enableKeyMapping = true;
      keyboard.remapCapsLockToControl = true;
      primaryUser = "adriano.caloiaro";
      stateVersion = 6;
    };
    users = {
      knownUsers = [ "adriano.caloiaro" ];
      users."adriano.caloiaro" = {
        uid = 502;
        shell = pkgs.fish;
        home = "/Users/adriano.caloiaro";
      };
    };
  };
}
