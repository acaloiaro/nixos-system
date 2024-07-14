# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  lib,
  pkgs,
  inputs,
  homeage,
  ...
}: {
  imports = [
    "${inputs.nixos-hardware}/raspberry-pi/4"
    ./hardware-configuration.nix
  ];

  boot = {
    kernelParams = ["kunit.enable=0" "snd_bcm2835.enable_hdmi=1"];
    supportedFilesystems = lib.mkForce ["f2fs" "ntfs" "cifs" "ext4" "vfat" "nfs" "nfs4" "zfs"];
    initrd.availableKernelModules = [
      "usbhid"
      "usb_storage"
      "vc4"
      "pcie_brcmstb" # required for the pcie bus to work
      "reset-raspberrypi" # required for vl805 firmware to load
    ];

    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };

    kernel.sysctl = {
      "net.ipv4.ip_forward" = "1";
      "net.ipv6.conf.all.forwarding" = "1";
    };
  };

  # Configure secrets
  age = {
    identityPaths = ["/home/pi/.ssh/id_rsa"];
    secrets = {
      tailscale_key = {
        file = ./secrets/tailscale_key.age;
      };
    };
  };

  sound.enable = true;
  hardware = {
    enableRedistributableFirmware = true;
    deviceTree.filter = lib.mkDefault "bcm2711-rpi-4-b.dtb";
    raspberry-pi."4".apply-overlays-dtmerge.enable = false;
    raspberry-pi."4".fkms-3d.enable = true;
    # raspberry-pi."4".audio.enable = true;
    pulseaudio.enable = true;
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

  # Build libcec with raspberrypi support
  nixpkgs.overlays = [
    (self: super: {libcec = super.libcec.override {withLibraspberrypi = true;};})
  ];
  nixpkgs.config.allowUnfree = true;

  time.timeZone = "America/Denver";
  i18n.defaultLocale = "en_US.UTF-8";
  services = {
    jellyfin = {
      enable = true;
      openFirewall = true;
    };
  };
  services.openssh.enable = true;
  services.xserver = {
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

  services.logind.extraConfig = ''
    IdleAction=sleep
    IdleActionSec=100000000000
  '';

  networking = {
    hostName = "roampi"; # Define your hostname.
    hostId = "0cb3361a";

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
    libcec
    libraspberrypi
    raspberrypi-eeprom
    zfs
    zfstools
  ];

  users.mutableUsers = true;
  users = {
    users.pi = {
      isNormalUser = true;
      initialPassword = "raspberrypi";
      extraGroups = ["wheel"]; # Enable ‘sudo’ for the user.
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQD1LwyUmY8yaaIfPKn9aUIsbm8NkcLvx8MOILtKubMxOvnJ+ZkOQnqve/KE+VNdvOzlZgnnLA24ZAeM5fD8n/WFVjDRsKqXVAfZOIygm2/P1RzEK5+AoVOeIC25DhizNGJ0pE8F4aSVTmTtOq5kOf1bTSuVhv3p/k6ZusrzBI2HOEOUg/sfs3Q1L7wHDHTA5qxqYACLebGocq0KqWPW4GTJ67XEMiNIENBh4EEEDTaeQZjRomeeR0ssDlrNAabf+vp+dxEtyHXS9dPznCFUIh7KyCx1oKLBl/O3B2NuVycXdo2yGpPGF6iKC6HW6lBHkYWfmgunQ4NOZWpbFFF0nT7K/kbFjmQKn3h7xuH3wXqs+iGXlDCQ1c/7YKarrD/JOsyWN/qHj9nto5QE40GZZRqhO1i16jCgMTyk0VLwZ5Eq6+zAKBKBQ2t/aFov4i05LuM3geg3LO4BoyQnP/ikuDb4ENRb1+wlJp9kCk2YKZeLwcgBXYg9xkXpX5ZnQl9E26s= adriano@zenity"
      ];
      packages = with pkgs; [
      ];
    };
  };

  fileSystems."/storage" = {
    device = "storage";
    depends = ["/run/cec.fifo"];
    fsType = "zfs";
  };

  # Allow normal users to use CEC
  services.udev.extraRules = ''
    # allow access to raspi cec device for video group (and optionally register it as a systemd device, used below)
    SUBSYSTEM=="vchiq", GROUP="video", MODE="0660", TAG+="systemd", ENV{SYSTEMD_ALIAS}="/dev/vchiq"
  '';

  systemd.sockets."cec-client" = {
    after = ["dev-vchiq.device"];
    bindsTo = ["dev-vchiq.device"];
    wantedBy = ["sockets.target"];
    socketConfig = {
      ListenFIFO = "/run/cec.fifo";
      SocketGroup = "video";
      SocketMode = "0660";
    };
  };

  systemd.services."cec-client" = {
    after = ["dev-vchiq.device"];
    bindsTo = ["dev-vchiq.device"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      ExecStart = ''${pkgs.libcec}/bin/cec-client -d 1'';
      ExecStop = ''/bin/sh -c "echo q &gt; /run/cec.fifo"'';
      StandardInput = "socket";
      StandardOutput = "journal";
      Restart = "no";
    };
  };

  # Enable tailscaled
  services.tailscale.enable = true;

  # create a oneshot job to authenticate to Tailscale
  systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";
    enable = true;

    # make sure tailscale is running before trying to connect to tailscale
    after = ["network-pre.target" "tailscale.service"];
    wants = ["network-pre.target" "tailscale.service"];
    wantedBy = ["multi-user.target"];

    # set this service as a oneshot job
    serviceConfig.Type = "oneshot";

    # have the job run this shell script
    script = with pkgs; ''
      # wait for tailscaled to settle
      sleep 2

      # check if we are already authenticated to tailscale
      status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
      if [ $status = "Running" ]; then # if so, then do nothing
        exit 0
      fi

      # otherwise authenticate with tailscale
      ${tailscale}/bin/tailscale up -authkey $(cat ${config.age.secrets.tailscale_key.path}) --accept-routes --advertise-routes=192.168.13.0/24 --reset
    '';
  };

  services = {
    syncthing = {
      enable = true;
      user = "pi";
      dataDir = "/home/pi/.config/syncthing";
      configDir = "/home/pi/.config/syncthing/config";
      guiAddress = "100.123.165.8:8384";
      overrideDevices = true; # overrides any devices added or deleted through the WebUI
      overrideFolders = true; # overrides any folders added or deleted through the WebUI
      devices = {
        "z1" = {id = "MXXILUU-IUTJYFM-5QW4SAL-SJB5EJY-NJ57ROO-OUI3KRK-G2AS3OU-7GXJKQU";};
      };
      folders = {
        "Documents" = {
          # Name of folder in Syncthing, also the folder ID
          path = "/home/pi/Documents"; # Which folder to add to Syncthing
          devices = ["z1"]; # Which devices to share the folder with
        };
      };
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
  system.stateVersion = "23.11"; # Did you read the comment?
}
