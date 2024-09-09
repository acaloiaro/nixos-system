# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  boot = {
    supportedFilesystems = lib.mkForce ["f2fs" "ntfs" "cifs" "ext4" "vfat" "nfs" "nfs4" "zfs"];
    initrd.availableKernelModules = [
      "usbhid"
      "usb_storage"
    ];

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      generationsDir.copyKernels = true;
    };

    kernel.sysctl = {
    };
  };

  # Configure secrets
  age = {
    identityPaths = ["/root/.ssh/id_rsa"];
    secrets = {
      tailscale_key = {
        file = ./secrets/tailscale_key.age;
      };
      wireless_networks = {
        file = ./secrets/wireless_networks.age;
      };
    };
  };

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  nixpkgs.config.allowUnfree = true;

  time.timeZone = "America/Denver";
  i18n.defaultLocale = "en_US.UTF-8";
  services = {
    transmission = {
      enable = true;
      settings = {
        rpc-bind-address = "100.98.79.116";
        download-dir = "/data/media";
        rpc-whitelist-enabled = "false";
      };
    };

    syncthing = {
      enable = false;
      user = "homebee";
      dataDir = "/home/homebee/.config/syncthing";
      configDir = "/home/homebee/.config/syncthing/config";
      guiAddress = "100.98.79.116:8384";
      overrideDevices = true; # overrides any devices added or deleted through the WebUI
      overrideFolders = true; # overrides any folders added or deleted through the WebUI
      devices = {
        "z1" = {id = "MXXILUU-IUTJYFM-5QW4SAL-SJB5EJY-NJ57ROO-OUI3KRK-G2AS3OU-7GXJKQU";};
      };
      folders = {
        "Documents" = {
          # Name of folder in Syncthing, also the folder ID
          path = "/home/homebee/Documents"; # Which folder to add to Syncthing
          devices = ["z1" "zw" "jellybee"]; # Which devices to share the folder with
        };
      };
    };
    adguardhome.enable = true;
    tailscale = {
      enable = true;
      authKeyFile = config.age.secrets.tailscale_key.path;
      extraSetFlags = ["--advertise-exit-node"];
    };
    jellyfin = {
      enable = true;
      openFirewall = true;
    };
    openssh.enable = true;
    xserver = {
      enable = true;
      layout = "us";
      xkbOptions = "caps:ctrl_modifier";

      windowManager.i3.enable = true;
      displayManager = {
        defaultSession = "none+i3";
      };

      desktopManager = {
        xterm.enable = false;
      };
    };

    logind.extraConfig = ''
      IdleAction=sleep
      IdleActionSec=100000000000
    '';
  };

  networking = {
    hostName = "homebee"; # Define your hostname.
    hostId = "0cb3361a";
    wireless = {
      enable = true;
      userControlled.enable = true;
      environmentFile = config.age.secrets.wireless_networks.path;
      networks = {
        "3216240371" = {
          psk = "@HOME5536@";
        };
      };
    };

    firewall = {
      # enable the firewall
      enable = true;

      # always allow traffic from your Tailscale network
      trustedInterfaces = ["tailscale0"];

      # allow the Tailscale UDP port through the firewall
      allowedUDPPorts = [config.services.tailscale.port];

      # allow you to SSH in over the public internet
      allowedTCPPorts = [22];
    };
  };

  environment.systemPackages = with pkgs; [
    git
    jq
    kitty
    tailscale
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    yt-dlp
    zfs
    zfstools
  ];

  users.mutableUsers = true;
  users = {
    users.homebee = {
      isNormalUser = true;
      initialPassword = "Jellybee1";
      extraGroups = ["wheel" "jellyfin"]; # Enable ‘sudo’ for the user.
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQD1LwyUmY8yaaIfPKn9aUIsbm8NkcLvx8MOILtKubMxOvnJ+ZkOQnqve/KE+VNdvOzlZgnnLA24ZAeM5fD8n/WFVjDRsKqXVAfZOIygm2/P1RzEK5+AoVOeIC25DhizNGJ0pE8F4aSVTmTtOq5kOf1bTSuVhv3p/k6ZusrzBI2HOEOUg/sfs3Q1L7wHDHTA5qxqYACLebGocq0KqWPW4GTJ67XEMiNIENBh4EEEDTaeQZjRomeeR0ssDlrNAabf+vp+dxEtyHXS9dPznCFUIh7KyCx1oKLBl/O3B2NuVycXdo2yGpPGF6iKC6HW6lBHkYWfmgunQ4NOZWpbFFF0nT7K/kbFjmQKn3h7xuH3wXqs+iGXlDCQ1c/7YKarrD/JOsyWN/qHj9nto5QE40GZZRqhO1i16jCgMTyk0VLwZ5Eq6+zAKBKBQ2t/aFov4i05LuM3geg3LO4BoyQnP/ikuDb4ENRb1+wlJp9kCk2YKZeLwcgBXYg9xkXpX5ZnQl9E26s= adriano@zenity"
      ];
      packages = with pkgs; [
      ];
    };
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
