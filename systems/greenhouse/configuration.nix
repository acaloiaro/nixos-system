{
  pkgs,
  inputs,
  ...
}: let
  primaryUser = "adriano.caloiaro";
in {
  imports = [
    ../../common/secrets.nix
  ];
  config = {
    age.secrets.opencode-github-mcp-pat.owner = "adriano.caloiaro";
    age.rekey = {
      hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE91Gv3hh4dkznl1o2+5xJQBEIvDVo7UWxjm93nQfRmE age-key-greenhouse";
      localStorageDir = ./. + "/secrets/rekeyed/";
    };
    environment = {
      etc = {
        "dict.conf".text = "server dict.org";
      };
      variables = {
        HOMEBREW_NO_ANALYTICS = "1";
        NH_FLAKE = "/Users/${primaryUser}/proj/nixos-system";
      };
      systemPackages = with pkgs; [
        age
        inputs.agenix.packages.${pkgs.system}.default
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
        "logseq"
        "maccy"
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
      settings.trusted-users = ["adriano.caloiaro"];
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
      knownUsers = [primaryUser];
      users."${primaryUser}" = {
        uid = 502;
        shell = pkgs.fish;
        home = "/Users/${primaryUser}";
      };
    };
  };
}
