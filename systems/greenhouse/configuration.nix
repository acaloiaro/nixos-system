{
  pkgs,
  ...
}:
let
  primaryUser = "adriano.caloiaro";
in
{
  imports = [
    ./../../common/development/virtualization/podman.nix
  ];
  config = {
    development.services.podman.enabled = true;
    environment = {
      etc = {
        "dict.conf".text = "server dict.org";
      };
      variables = {
        HOMEBREW_NO_ANALYTICS = "1";
        NH_FLAKE = "/Users/${primaryUser}/proj/nixos-system";
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
        # cleanup = "zap";
        upgrade = true;
      };
      brews = [
        "coreutils"
        "podman" # Podman-desktop needs podman to be in a non-nix path, and since it checks homebrew's bin, we install it with homebrew
        "krunkit"
        {
          name = "pulseaudio";
          restart_service = "changed";
          start_service = true;
        }
        "vfkit" # Used by podman for virtualization
      ];
      # Update these applicatons manually.
      # As brew would update them by unninstalling and installing the newest
      # version, it could lead to data loss.
      casks = [
        "beeper"
        "logseq"
        "podman-desktop"

        "spotify"
        "vlc"
      ];
      taps = [
        "slp/krunkit" # Needed by podman-desktop/podman
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
        browser = "chrome"; # or "chrome", "safari", "dia", etc.
      };
    };
    system = {
      keyboard.enableKeyMapping = true;
      keyboard.remapCapsLockToControl = true;
      primaryUser = primaryUser;
      stateVersion = 6;
    };
    users = {
      knownUsers = [ primaryUser ];
      users."${primaryUser}" = {
        uid = 502;
        shell = pkgs.fish;
        home = "/Users/${primaryUser}";
      };
    };
  };
}
