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
    ./disko.nix
    ../../common/services/opencloud.nix
    ../../common/services/silverbullet.nix
    ../../common/services/tailscale-serve.nix
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
      "net.ipv4.ip_forward" = "1";
      "net.ipv6.conf.all.forwarding" = "1";
    };
  };

  # Configure secrets
  age = {
    identityPaths = ["/root/.ssh/id_rsa_jellybee"];
    rekey = {
      hostPubkey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC9cmF9B0y4t0q02W7blS+AHpN5pt6E55bABwoIhtPA4Vwq2Cxi35T/DlnyKPQq2jL3eIALrSR0C3A3ASlEQHext1MV1x8rSo+Z8ouN0GL1vn208e7tDgCt3FbhkgrNoUTAbpvsRXjwFXPB4TbYfb3rhVxzoGXd/+AfdHGNUUyfA//loy9/rfFac8dGqLkxv30Doa6fT00El5ohQ4DuVvSREdFF070GzlX4TKjNz2Tr2D0FcXTHVbJxbcjDucSgoc+kE2fvmXm598nX0sczYSXTCcv+PHkcfwHpo+M5JBlpIP43RANghk5ILaxRFf9/qz8Loe3RhuZd6uZ7xS4hyf6wcBcf7LiiKdctZFkyiSSUXvVVH/gmHNWJa01gs2F/n+hglXitWDWmadTa5pEkT0jjv9eN4q0t5HAPdu5z6pNsHe02mrQZu97vimf/q6x1dXNoBiEd3tGrzsFytawl7l6LvZ91qI5eSflupn5C8qnSlvvuEPNwjmgyEZ46Oz3/Xp2EZPSWjw7JFvfb9hNUUqYsr54bG70l9sITxdSXQvVENAfwA3+129eycSyl7BsrqAdUOrbZKEnxyHC9QB/quzUz765OCW64ZGTr36mhCdQTWtKYq8NWWvKOi1fI/TnCp8FkRtEM2GAo1DNPKrFdhkHruiE83URkevt5ipvfJ6ZHUw== code@adriano.fyi";
      localStorageDir = ./. + "/secrets/rekeyed/${config.networking.hostName}";
    };

    secrets = {
      tailscale_key = {
        file = ./secrets/tailscale_key.age;
      };
      wireless_networks = {
        file = ./secrets/wireless_networks.age;
        owner = "wpa_supplicant";
        group = "wpa_supplicant";
      };
      nix_serve_cache_key = {
        file = ./secrets/nix_serve_cache_key.age;
        mode = "400";
        owner = "nix-serve";
        group = "nix-serve";
      };
      opencloud_b2 = {
        rekeyFile = ./secrets/opencloud_b2.age;
      };
    };
  };

  nix = {
    package = pkgs.nixVersions.stable;
    settings = {
      warn-dirty = false;
      trusted-users = ["root" "jellybee"];
    };
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  my = {
    opencloud = {
      enable = true;
      hostname = "jellybee.bison-lizard.ts.net:9200";
      s3 = {
        endpoint = "https://s3.us-east-005.backblazeb2.com";
        region = "us-east-005";
        bucket = "oc-adriano-fyi";
        credentialsFile = config.age.secrets.opencloud_b2.path;
      };
    };
    services.silverbullet = {
      enable = true;
      dataDir = "/mnt/opencloud/adriano/silverbullet";
      webdav = {
        enable = true;
        url = "https://jellybee.bison-lizard.ts.net:9200/remote.php/dav/spaces/094a577f-1bfd-483e-ae2a-d277cb24bb11$baa79013-0ccf-4ab1-ad5c-45299685c50f"; # Adriano's 'Personal'
        mountPoint = "/mnt/opencloud";
      };
    };
  };
  nixpkgs.config.allowUnfree = true;

  time.timeZone = "America/Denver";
  i18n.defaultLocale = "en_US.UTF-8";

  services = {
    adguardhome.enable = true;
    displayManager = {
      defaultSession = "none+i3";
    };
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
      xkb = {
        options = "caps:ctrl_modifier";
        layout = "us";
      };
      windowManager.i3.enable = true;

      desktopManager = {
        xterm.enable = false;
      };
    };

    nix-serve = {
      enable = true;
      secretKeyFile = config.age.secrets.nix_serve_cache_key.path;
      port = 5676;
      bindAddress = "0.0.0.0";
      package = pkgs.nix-serve-ng;
    };
  };

  networking = {
    hostName = "jellybee"; # Define your hostname.
    hostId = "0cb3361b";

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

    interfaces = {
      wlo1.useDHCP = true;
      enp1s0.useDHCP = true;
      # This was a static IP until the patch cable stopped working. Now we reserve .103 for wlo1 on the router.
      # enp1s0 = {
      #   ipv4.addresses = [
      #     {
      #       address = "192.168.13.103";
      #       prefixLength = 24;
      #     }
      #   ];
      # };
    };

    wireless = {
      enable = true;
      userControlled = true;
      secretsFile = config.age.secrets.wireless_networks.path;
      networks = {
        "roam" = {
          pskRaw = "ext:ROAM_PSK";
        };
        "MyOptimum c647cd" = {
          psk = "8328-emerald-20";
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [
    git
    helix
    jq
    kitty
    tailscale
    ungoogled-chromium
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    wpa_supplicant_gui
    yt-dlp
    zfs
    zfstools
  ];

  users.mutableUsers = true;
  users = {
    groups = {
      "nix-serve" = {};
    };
    users.jellybee = {
      isNormalUser = true;
      initialPassword = "Jellybee1";
      extraGroups = ["wheel" "jellyfin"]; # Enable 'sudo' for the user.
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQD1LwyUmY8yaaIfPKn9aUIsbm8NkcLvx8MOILtKubMxOvnJ+ZkOQnqve/KE+VNdvOzlZgnnLA24ZAeM5fD8n/WFVjDRsKqXVAfZOIygm2/P1RzEK5+AoVOeIC25DhizNGJ0pE8F4aSVTmTtOq5kOf1bTSuVhv3p/k6ZusrzBI2HOEOUg/sfs3Q1L7wHDHTA5qxqYACLebGocq0KqWPW4GTJ67XEMiNIENBh4EEEDTaeQZjRomeeR0ssDlrNAabf+vp+dxEtyHXS9dPznCFUIh7KyCx1oKLBl/O3B2NuVycXdo2yGpPGF6iKC6HW6lBHkYWfmgunQ4NOZWpbFFF0nT7K/kbFjmQKn3h7xuH3wXqs+iGXlDCQ1c/7YKarrD/JOsyWN/qHj9nto5QE40GZZRqhO1i16jCgMTyk0VLwZ5Eq6+zAKBKBQ2t/aFov4i05LuM3geg3LO4BoyQnP/ikuDb4ENRb1+wlJp9kCk2YKZeLwcgBXYg9xkXpX5ZnQl9E26s= adriano@zenity"
      ];
    };

    users."nix-serve" = {
      isSystemUser = true;
      group = "nix-serve";
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
