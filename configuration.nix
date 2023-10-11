# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).
{ config, pkgs, inputs, ...}: {

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./zfs.nix
    ];

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

  # Configure secrets 
  age = {
    identityPaths = [ "/root/.ssh/id_rsa_z1" ];
    secrets = {
      wireless_networks = {
        file = ./secrets/wireless_networks.age;
      };
      
      tailscale_key = {
        file = ./secrets/tailscale_key.age;
      };
    };
  };

  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  environment.pathsToLink = [ "/libexec" ];
  programs.dconf.enable = true;

  networking.hostName = "z1"; # Define your hostname.
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.wireless.environmentFile = config.age.secrets.wireless_networks.path;
  networking.wireless.networks = {
    roam = {
      psk = "@ROAM_PSK@";
      priority = 1;
    };
    Miniroam = {
      psk = "@MINIROAM_PSK@";
      priority = 2;
    };
    "DeltaSkyClub" = {
      priority = 3;
    };
    "TheCenturionLounge" = {
      priority = 4;
    };
    "KOTART" = {
      psk = "$Pring123";
    };
  };

  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  fonts.packages = with pkgs; [ 
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
    roboto 
    font-awesome_5 
  ];
  console = {
    font = "roboto";
    useXkbConfig = true; # use xkbOptions in tty.
  };

  # Set your time zone.
  time.timeZone = "America/Denver";

  # Enable bluetooth and sound
  hardware.pulseaudio.enable = true;
  hardware.bluetooth.enable = true;  
  sound.enable = true;
  services.dbus.enable = true;
  services.blueman.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    mutableUsers = true;
    users.adriano = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "docker" ]; # Enable ‘sudo’ for the user.
      password = "Iliketochangeitchangeit";
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQD1LwyUmY8yaaIfPKn9aUIsbm8NkcLvx8MOILtKubMxOvnJ+ZkOQnqve/KE+VNdvOzlZgnnLA24ZAeM5fD8n/WFVjDRsKqXVAfZOIygm2/P1RzEK5+AoVOeIC25DhizNGJ0pE8F4aSVTmTtOq5kOf1bTSuVhv3p/k6ZusrzBI2HOEOUg/sfs3Q1L7wHDHTA5qxqYACLebGocq0KqWPW4GTJ67XEMiNIENBh4EEEDTaeQZjRomeeR0ssDlrNAabf+vp+dxEtyHXS9dPznCFUIh7KyCx1oKLBl/O3B2NuVycXdo2yGpPGF6iKC6HW6lBHkYWfmgunQ4NOZWpbFFF0nT7K/kbFjmQKn3h7xuH3wXqs+iGXlDCQ1c/7YKarrD/JOsyWN/qHj9nto5QE40GZZRqhO1i16jCgMTyk0VLwZ5Eq6+zAKBKBQ2t/aFov4i05LuM3geg3LO4BoyQnP/ikuDb4ENRb1+wlJp9kCk2YKZeLwcgBXYg9xkXpX5ZnQl9E26s= adriano@zenity"	 ];
      packages = with pkgs; with inputs; [
        abook
        clipmenu
        ctags
        dante
        dict
        di-tui.packages.${system}.default
        direnv
        dmenu
        ess.packages.${system}.default
        fzf
        gcc8
        glow
        gnumake
        gopass
        gopass-jsonapi
        hugo
        inetutils
        kitty
        language-servers.packages.${system}.vscode-langservers-extracted # For vscode-html-language-server, vscode-css-language-server, vscode-json-language-server in Helix
        lazygit
        ltex-ls
        chatgpt-cli
        git
        go
        gopls	
        gscreenshot
        ivpn
        jq
        nextcloud-client
        nix-index
        nodejs
        nodePackages.typescript-language-server
        nomad_1_4
        nil # nix lsp
        python310Packages.python-lsp-server
        ripgrep
        rofi
        spotify-tui
        tailscale
        terraform
        terraform-lsp
        texlive.combined.scheme-tetex
        tmux
        pandoc 
        python3
        simplescreenrecorder
        speedtest-cli
        tree
        w3m
        xclip
        unzip
      ];
    };   
  };

  environment.etc."dict.conf".text = "server dict.org";
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim
    wget
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs.zsh = {
    enable = true;
  };

  # List services that you want to enable:
  services.tailscale.enable = true;
  services.ivpn.enable = true;
  services.openntpd.enable = true;
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };
  services.redis.servers."z1".enable=true;
  services.redis.servers."z1".port=6379;

  services.xserver = {
    enable = true;
    layout = "us";
    xkbOptions = "caps:ctrl_modifier";
    windowManager.i3.enable = true;
    desktopManager = {
      xterm.enable = false;
    };

    displayManager = {
      defaultSession = "none+i3";
    };

    libinput = {
      enable = true;
      touchpad = {
        naturalScrolling = true;
        accelSpeed = "0.5";
        disableWhileTyping = true;
        additionalOptions = ''
          Option "PalmDetection" "on"
        '';
      };
    };    

    # Can't figure out how to enable natural scrolling. Ideally what I want is natural scrolling AND palm detection, 
    # but for now, it seems like I can't have both without getting my hands more dirty. Switching back to libinput 
    synaptics = {
      enable = false;
      palmDetect = true;
      maxSpeed = "2.0";
      accelFactor = "0.01";
      twoFingerScroll = true;
    };
  };

  # Backlight/brightness control
  programs.light.enable = true;
  services.actkbd = {
    enable = true;
    bindings = [
      { keys = [ 225 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -A 10"; }
      { keys = [ 224 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -U 10"; }
      { keys = [ 114 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/runuser -l adriano -c 'amixer -q set Master 5%- unmute'"; }
      { keys = [ 115 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/runuser -l adriano -c 'amixer -q set Master 5%+ unmute'"; }
    ];
  };

  # create a oneshot job to authenticate to Tailscale
  systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";
    enable = true;

    # make sure tailscale is running before trying to connect to tailscale
    after = [ "network-pre.target" "tailscale.service" ];
    wants = [ "network-pre.target" "tailscale.service" ];
    wantedBy = [ "multi-user.target" ];

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
      ${tailscale}/bin/tailscale up -authkey $(cat ${config.age.secrets.tailscale_key.path}) --accept-routes 
    '';
  };

  systemd.services.address-book-sync = {
    description = "Syncs the Fastmail address book";
    enable = true;
    serviceConfig.User = "adriano";
    serviceConfig.Type = "oneshot";
    script = with pkgs; ''
      tmpfile=$(mktemp)
      destfile=$(mktemp)

      ${wget}/bin/wget -q https://carddav.fastmail.com/dav/addressbooks/user/me@adriano.fyi/Default \
          --user me@adriano.fyi \
          --password $(${gopass}/bin/gopass show fastmail.com/me-aerc | head -n 1) \
          -O $tmpfile

      ${abook}/bin/abook --convert \
          --informat vcard \
          --infile $tmpfile \
          --outformat abook \
          --outfile $destfile

      rm $tmpfile
      chmod 600 $destfile
      mv $destfile ~/.abook/addressbook
    '';
  };

  systemd.timers.address-book-sync = {
    wantedBy = [ "timers.target" ];
    partOf = [ "address-book-sync.service" ];
    timerConfig = {
      OnCalendar = "*-*-* 00:00:00";
      
    };
  };

  networking.firewall = {
    # enable the firewall
    enable = true;

    # always allow traffic from your Tailscale network
    trustedInterfaces = [ "tailscale0" ];

    # allow the Tailscale UDP port through the firewall
    allowedUDPPorts = [ config.services.tailscale.port ];

    # allow you to SSH in over the public internet
    allowedTCPPorts = [ 22 ];
  };


  services.postgresql = {
    enable = true;
    ensureDatabases = [ "neoq" ];
    enableTCPIP = true;
    # port = 5432;
    authentication = pkgs.lib.mkOverride 10 ''
    local all       all     trust
    # ipv4
    host  all      all     127.0.0.1/32   trust
    # ipv6
    host all       all     ::1/128        trust
    '';
    
    initialScript = pkgs.writeText "backend-initScript" ''
      CREATE ROLE postgres WITH LOGIN PASSWORD 'postres' CREATEDB;
      CREATE DATABASE neoq;
      GRANT ALL PRIVILEGES ON DATABASE neoq TO postgres;
      LOAD 'auto_explain';
      '';

    settings = {
      log_statement = "all";
      "auto_explain.log_analyze" = "true";
      "auto_explain.log_nested_statements" = "on";
      "auto_explain.log_min_duration" = 0;
      "auto_explain.log_triggers" = "true";
      max_connections = 2000;
      log_connections = "yes";
      logging_collector = "on";
      log_directory = "/tmp/";
      log_filename = "postgresql-%Y-%m-%d_%H%M%S.log";
      log_truncate_on_rotation = "true";
      log_rotation_age = 1440;
      client_min_messages = "LOG";
      log_min_messages = "INFO";
      log_min_error_statement = "DEBUG5";
      log_min_duration_statement = 0;
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
  system.stateVersion = "23.05"; # Did you read the comment?

}
