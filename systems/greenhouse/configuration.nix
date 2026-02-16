{
  pkgs,
  inputs,
  ...
}: let
  primaryUser = "adriano.caloiaro";
in {
  imports = [
    ../../common/secrets.nix
    ../../common/binary-cache.nix
  ];
  config = {
    substituters.private.enable = false;
    age = {
      identityPaths = [
        "/Users/adriano.caloiaro/.ssh/id_ed25519_age"
      ];
      rekey = {
        hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE91Gv3hh4dkznl1o2+5xJQBEIvDVo7UWxjm93nQfRmE age-key-greenhouse";
        localStorageDir = ./. + "/secrets/rekeyed";
      };
      secrets = {
        opencode-github-mcp-pat = {
          rekeyFile = ../../common/secrets/opencode-github-mcp-pat.age;
          owner = "adriano.caloiaro";
          mode = "400";
        };
      };
    };
    environment = {
      etc = {
        "dict.conf".text = "server dict.org";
      };
      variables = {
        HOMEBREW_NO_ANALYTICS = "1";
      };
      systemPackages = with pkgs; [
        age
        gnupg
        gopass
        helix
        inputs.agenix-rekey.packages.${system}.default
        nh
        ripgrep
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
      masApps = {
        # Tailscale = 1475387142; # App Store URL id (keep for example purposes)
      };
    };
    nix = {
      settings.warn-dirty = false;
      settings.experimental-features = "nix-command flakes";
      settings.trusted-users = ["adriano.caloiaro"];
      settings.connect-timeout = 5;
    };
    nixpkgs.hostPlatform = "aarch64-darwin";
    programs = {
      zsh.enable = true;
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
        shell = pkgs.zsh;
        home = "/Users/${primaryUser}";
      };
    };
  };
}
