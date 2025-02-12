# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).
{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./zfs.nix
    ../../common/1password.nix
    ../../common/podman.nix
    ./hosts-config.nix
  ];

  config = {
    _1password = {
      enable = true;
      user = "adriano";
    };

    # Configure secrets
    age = {
      identityPaths = ["/root/.ssh/id_rsa_agenix"];
      secrets = {
        wireless_networks = {
          file = ./secrets/wireless_networks.age;
        };

        tailscale_key = {
          file = ./secrets/tailscale_key.age;
        };
      };
    };

    boot = {
      kernel.sysctl = {
        "net.ipv4.ip_unprivileged_port_start" = 80;
      };
    };
    console = {
      font = "Isoveke";
      useXkbConfig = true; # use xkbOptions in tty.
    };

    environment.sessionVariables.FLAKE = "/home/adriano/git/nixos-system";

    environment.etc."dict.conf".text = "server dict.org";
    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
      neovim
      wget
    ];

    environment.pathsToLink = ["/libexec"];

    fonts = {
      packages = with pkgs; [
        nerd-fonts.fira-code
        nerd-fonts.iosevka
        roboto
        font-awesome_5
        ubuntu_font_family
        noto-fonts
        noto-fonts-color-emoji
        iosevka
      ];
      fontconfig = {
        defaultFonts = {
          sansSerif = ["Iosevka" "Noto Color Emoji"];
          serif = ["Iosevka" "Noto Color Emoji"];
          emoji = ["Noto Color Emoji"];
        };
      };
    };

    hardware.bluetooth.enable = true;
    hardware.gpgSmartcards.enable = true;
    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-compute-runtime
        intel-media-driver
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
      ];
    };

    nix = {
      package = pkgs.nixVersions.stable;
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
      settings = {
        trusted-users = ["root" "adriano"];
        substituters = [
          "https://nix-community.cachix.org"
          "https://cache.nixos.org/"
        ];
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
      };
    };

    # Select internationalisation properties.
    i18n = {
      defaultLocale = "en_US.UTF-8";
      supportedLocales = [
        "en_US.UTF-8/UTF-8"
      ];
    };
    networking.hostName = "zw"; # Define your hostname.
    networking.nameservers = ["1.1.1.1"];

    networking.wireless = {
      enable = true;
      userControlled.enable = true;
      secretsFile = config.age.secrets.wireless_networks.path;
      networks = {
        "MTShadows" = {
          psk = "WinterChills";
          priority = 100;
        };
        "labarbacoffee" = {
          psk = "labarbadraper";
          priority = 100;
        };
        "roam" = {
          pskRaw = "ext:ROAM_PSK";
          priority = 2;
        };
        "WGCR-2" = {
          psk = "Goose2010";
        };
        Miniroam = {
          pskRaw = "ext:MINIROAM_PSK";
          priority = 99;
        };
        "DeltaSkyClub" = {
          priority = 3;
        };
        "TheCenturionLounge" = {
          priority = 4;
        };
        "Bonjour Bakery Cafe_5G" = {
          psk = "bakedgoods";
        };
        "CatskillHouse" = {
          pskRaw = "ext:CATSKIPP_HOUSE";
        };
        "Hilton Honors" = {
          priority = 100;
        };
        "Lannae" = {
          psk = "LannaeLove503";
        };
        "3216240371" = {
          pskRaw = "ext:HOME5536";
        };
        "Magnus" = {
          pskRaw = "ext:MAGNUS";
        };
        "James Coffee_EXT" = {
          psk = "coffeecoffee";
        };
        "Manzanita Cafe" = {
          psk = "Manzanita2024";
        };
        "Caje" = {
          psk = "cocktails";
        };
        "Feel love WiFi" = {
          psk = "namaste1";
        };
        "SURV-Guest100" = {
          pskRaw = "ext:SURV";
        };
      };
    };

    networking.firewall = {
      # enable the firewall
      enable = true;

      # always allow traffic from your Tailscale network
      trustedInterfaces = ["tailscale0"];

      # allow the Tailscale UDP port through the firewall
      allowedUDPPorts = [config.services.tailscale.port];

      # allow you to SSH in over the public internet
      allowedTCPPorts = [22];
    };

    localServices.podman = {
      enable = true;
    };

    programs.fish = {
      enable = true;
    };
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 3";
      flake = "/home/adriano/git/nixos-system";
    };
    programs.dconf.enable = true;
    programs.i3lock.u2fSupport = true;

    # Backlight/brightness control
    programs.light.enable = true;

    # Fingerprint auth
    services.fprintd.enable = true;

    # Alsa
    services.pipewire.alsa.enable = true;

    # Yubikey
    services.udev.packages = [pkgs.yubikey-personalization];

    # lock screen un unplug
    services.udev.extraRules = ''
      ACTION=="remove",\
       ENV{ID_BUS}=="usb",\
       ENV{ID_MODEL_ID}=="0407",\
       ENV{ID_VENDOR_ID}=="1050",\
       ENV{ID_VENDOR}=="Yubico",\
       RUN+="${pkgs.systemd}/bin/loginctl lock-sessions"
    '';

    # Login and sudo with
    security.pam = {
      u2f = {
        settings = {
          cue = true; # Show prompt when u2f is being requested, e.g. for sudo
        };
        control = "sufficient"; # Yubikey is sufficient for authentication, no second factor required
      };

      services = {
        login.u2fAuth = true;
        sudo.u2fAuth = true;
        i3lock.u2fAuth = true;
      };
    };

    # Smartcard support
    services.pcscd.enable = true;
    services.dbus.enable = true;
    services.blueman.enable = true;
    services.tailscale = {
      authKeyFile = config.age.secrets.tailscale_key.path;
      enable = true;
    };
    services.ivpn.enable = true;
    services.openntpd.enable = true;
    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = true;
    };

    services.libinput = {
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

    services.displayManager = {
      defaultSession = "none+i3";
    };
    services.xserver = {
      enable = true;
      xkb = {
        options = "caps:ctrl_modifier";
        layout = "us";
      };
      windowManager.i3.enable = true;
      desktopManager = {
        xterm.enable = false;
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

    services.actkbd = {
      enable = true;
      bindings = [
        {
          keys = [225];
          events = ["key"];
          command = "/run/current-system/sw/bin/light -A 10";
        }
        {
          keys = [224];
          events = ["key"];
          command = "/run/current-system/sw/bin/light -U 10";
        }
        {
          keys = [114];
          events = ["key"];
          command = "/run/current-system/sw/bin/runuser -l adriano -c 'amixer -q set Master 5%- unmute'";
        }
        {
          keys = [115];
          events = ["key"];
          command = "/run/current-system/sw/bin/runuser -l adriano -c 'amixer -q set Master 5%+ unmute'";
        }
      ];
    };

    services.postgresql = {
      enable = false;
      ensureDatabases = ["neoq"];
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

    services = {
      syncthing = {
        enable = true;
        user = "adriano";
        dataDir = "/home/adriano/.config/syncthing";
        configDir = "/home/adriano/.config/syncthing/config";
        guiAddress = "100.81.21.118:8384";
        overrideDevices = true; # overrides any devices added or deleted through the WebUI
        overrideFolders = true; # overrides any folders added or deleted through the WebUI
        settings = {
          devices = {
            "z1" = {id = "MXXILUU-IUTJYFM-5QW4SAL-SJB5EJY-NJ57ROO-OUI3KRK-G2AS3OU-7GXJKQU";};
            "roampi" = {id = "PD2KG67-FKNO6QS-UTY24Q7-L6QQM6B-KL5NYMZ-A5HKAEH-4VYLSZR-WCCBPQT";};
            "Miniroam" = {id = "F7UWLCE-JPZXXU2-4SHXZ3X-BM3T3U7-DTSVPVA-TXFYB67-5TCR574-MSYRJQR";};
            "homepi" = {id = "CGBRCYB-2USPMPW-VKMVC4N-7SF2QLX-W5WWKHX-YD22FCO-XFNTJPC-RCKW5AY";};
            "Megaroam" = {id = "6SRZN3S-POHIH7U-NGJUAVE-MZU6DDF-O74WU5W-VBJ4TAE-5WZTYOV-7GVIIAF";};
          };
          folders = {
            "Documents" = {
              # Name of folder in Syncthing, also the folder ID
              path = "/home/adriano/Documents"; # Which folder to add to Syncthing
              devices = ["roampi" "Miniroam" "homepi" "z1" "Megaroam"]; # Which devices to share the folder with
            };
            "KB" = {
              # Name of folder in Syncthing, also the folder ID
              path = "/home/adriano/KB"; # Which folder to add to Syncthing
              devices = ["roampi" "Miniroam" "homepi" "z1" "Megaroam"]; # Which devices to share the folder with
            };
          };
        };
      };
    };

    # Only allow authentication with my serial id
    security.pam.yubico = {
      enable = true;
      debug = false;
      mode = "challenge-response";
      id = ["24654932"];
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
        mkdir -p ~/.abook
        mv $destfile ~/.abook/addressbook
      '';
    };

    systemd.services.khal-notify = {
      description = "Calendar notification with i3-nagbar";
      enable = true;
      environment = {
        DISPLAY = ":0";
      };
      serviceConfig.User = "adriano";
      serviceConfig.Type = "simple";
      script = with pkgs; ''
        set -euo pipefail
        trap 'echo "ERROR: $BASH_SOURCE:$LINENO $BASH_COMMAND" >&2' ERR

        function clean_iconv {
        	${iconv}/bin/iconv -c -t UTF-8
        }

        function clean_grep {
        	${gnugrep}/bin/grep -axv '.*'
        }
        if which iconv &>/dev/null; then
        	clean=clean_iconv
        else
        	clean=clean_grep
        fi

        #set -x
        lastturn=$(date +%s -d"now - 120 minutes")
        while true; do
        	turn=$(( $(date +%s) / 60 * 60 ))
          ${khal}/bin/khal list -f $'{start}\3 {title}\3{description}\3\4' -df ''' today \
          | while IFS= read -rd $'\4' e; do
        		begin=$(date -d"$(cut <<<"$e" -z -d$'\3' -f1 | tr -d \\0)" +%s)
        		title="$(cut <<<"$e" -z -d$'\3' -f2 | tr -d \\0)"
        		desc="$(cut <<<"$e" -z -d$'\3' -f3 | tr -d \\0 | cut -c-50)"
        		notify=false
        		for n in 3 15; do
        			if test $lastturn -lt $(( $begin - 60 * $n )) && test $(( $begin - 60 * $n )) -le $turn; then
        				in=$(( ($begin - $(date +%s)) / 60 ))
        				prio=low
        				if test $in -lt 5; then
        					prio=critical
        				elif test $in -lt 16; then
        					prio=warning
        				fi
        				if test $in -gt 0; then
        					in="In $in min."
        				else
        					in="$(( - $in )) min. ago"
        				fi
        				echo "Reminding of $title ($in)"
        				${i3}/bin/i3-nagbar -t $prio -m "$in: $title $desc" || echo notify-send failed
        				break
        			fi
        		done
        	done
        	lastturn=$turn
        	snooze=$(( $turn + 60 - $(date +%s) ))
        	if test $snooze -gt 0; then
        		sleep $snooze
        	fi
        done
      '';
    };
    systemd.timers.address-book-sync = {
      wantedBy = ["timers.target"];
      partOf = ["address-book-sync.service"];
      timerConfig = {
        OnCalendar = "*-*-* 00:00:00";
      };
    };

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It's perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "23.05"; # Did you read the comment?

    time.timeZone = "America/Denver";

    # Enable touchpad support (enabled default in most desktopManager).
    # Define a user account. Don't forget to set a password with ‘passwd’.
    users = {
      mutableUsers = true;
      users.adriano = {
        isNormalUser = true;
        extraGroups = ["wheel" "networkmanager" "docker"]; # Enable ‘sudo’ for the user.
        password = "Iliketochangeitchangeit";
        shell = pkgs.fish;
        openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQD1LwyUmY8yaaIfPKn9aUIsbm8NkcLvx8MOILtKubMxOvnJ+ZkOQnqve/KE+VNdvOzlZgnnLA24ZAeM5fD8n/WFVjDRsKqXVAfZOIygm2/P1RzEK5+AoVOeIC25DhizNGJ0pE8F4aSVTmTtOq5kOf1bTSuVhv3p/k6ZusrzBI2HOEOUg/sfs3Q1L7wHDHTA5qxqYACLebGocq0KqWPW4GTJ67XEMiNIENBh4EEEDTaeQZjRomeeR0ssDlrNAabf+vp+dxEtyHXS9dPznCFUIh7KyCx1oKLBl/O3B2NuVycXdo2yGpPGF6iKC6HW6lBHkYWfmgunQ4NOZWpbFFF0nT7K/kbFjmQKn3h7xuH3wXqs+iGXlDCQ1c/7YKarrD/JOsyWN/qHj9nto5QE40GZZRqhO1i16jCgMTyk0VLwZ5Eq6+zAKBKBQ2t/aFov4i05LuM3geg3LO4BoyQnP/ikuDb4ENRb1+wlJp9kCk2YKZeLwcgBXYg9xkXpX5ZnQl9E26s= adriano@zenity"
        ];
        packages = with pkgs;
        with inputs; [
          abook
          activitywatch
          alejandra
          alsa-utils
          beeper
          chawan
          clipmenu
          ctags
          dante
          dict
          dig
          di-tui
          direnv
          dmenu
          ess.packages.${system}.default
          fprintd
          fzf
          gimp
          glow
          gnumake
          gopass
          gopass-jsonapi
          hugo
          inetutils
          kitty
          lazygit
          libreoffice
          ltex-ls
          chatgpt-cli
          git
          go_1_23
          gopls
          golangci-lint-langserver
          golangci-lint
          gscreenshot
          icdiff
          ivpn
          jq
          jujutsu
          logseq
          nix-index
          ncdu
          nodejs
          nodePackages.typescript-language-server
          nomad_1_7
          nil # nix lsp
          nushell
          opentofu
          playerctl
          podman
          python311Packages.sqlparse
          qrencode
          ripgrep
          rofi
          sils.packages.${system}.default
          shutter
          stripe-cli
          slack
          spotify-player
          tailscale
          taplo
          terraform
          terraform-lsp
          tmux
          ungoogled-chromium
          usbutils
          pandoc
          python3
          simplescreenrecorder
          speedtest-cli
          tree
          vlc
          vscode-langservers-extracted
          weechat
          widevine-cdm
          w3m
          wpa_supplicant_gui
          xclip
          xsel
          unzip
          yubikey-manager
          zeal
          zoom-us
        ];
      };
    };

    virtualisation = {
      podman = {
        enable = true;
        dockerCompat = true;
        # Required for containers under podman-compose to be able to talk to each other.
        defaultNetwork.settings.dns_enabled = true;
      };
    };
  };
}
