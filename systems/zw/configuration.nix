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
    ../../common/virtualization/podman.nix
    ../../common/secrets.nix
    ../../common/binary-cache.nix
    ./hosts-config.nix
  ];

  config = {
    age = {
      identityPaths = ["/root/.ssh/id_rsa_agenix"];
      rekey = {
        hostPubkey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCx/tvR11RUMbYaauuHPxR3j79vm1Hxg+Y3LXR+rLgZ7N/2ulvIzLLZgVuIUbmJHDqkp9Au5zZPMZjsKbaqQ8V75wSEcyaSMbaxC9PaNDCwEHMJWaz8XPQe5IjVRE5O+4sTyh7ZBx+NMQmPcQbrNInoKuy4EjFmwTW/t0xYo/sCrC0NX0cCyeBwii2JdFXytXfxF+RMzGNXw1xfcOFJe6F7JdS/Cpf/0fe+VmNg8d0nic4Obcb/djYsRLAAC6Cvb+4i3EBZWl+9Ih9hId8bFCRKhI6TmGT2z4YUTa+v+3j/JZUh1gD5n4vRGf8QjLj9N6DrBnKcbywwqyqnLhTLgBBN35rcLdU1k3n0NorRRDCU0Lg/ejsFe3oi2FmOwNmmd8zqBNZHjJTi5Wy63EXMFwHltEY2M+hAhgWsQ5U4zuVPgv1HfD6LYPodRwhdZivwTNr2IClAiVVxR//O0WtrRXrrEM5uudj+Y30/ah7bn9Mje86UV0TqfS2tdjtMkySHL+M= adriano@z1";
        localStorageDir = ./. + "/secrets/rekeyed/${config.networking.hostName}";
      };
      secrets = {
        opencode-github-mcp-pat = {
          owner = "adriano";
        };
        tailscale_key = {
          file = ./secrets/tailscale_key.age;
        };
        wireless_networks = {
          file = ./secrets/wireless_networks.age;
          owner = "wpa_supplicant";
        };
      };
    };

    boot = {
      kernel.sysctl = {
        "net.ipv4.ip_unprivileged_port_start" = 80;
      };
    };

    console = {
      useXkbConfig = true; # use xkbOptions in tty.
    };

    environment = {
      etc."dict.conf".text = "server dict.org";
      pathsToLink = ["/libexec"];
      sessionVariables.FLAKE = "/home/adriano/git/nixos-system";
      systemPackages = with pkgs; [
        inputs.agenix-rekey.packages.${system}.default
        neovim
        wget
        zsh
      ];
    };

    fonts = {
      fontconfig = {
        defaultFonts = {
          emoji = ["Noto Color Emoji"];
          sansSerif = ["Iosevka" "Noto Color Emoji"];
          serif = ["Iosevka" "Noto Color Emoji"];
        };
      };
      packages = with pkgs; [
        font-awesome_5
        iosevka
        nerd-fonts.fira-code
        nerd-fonts.iosevka
        noto-fonts
        noto-fonts-color-emoji
        roboto
        ubuntu-classic
      ];
    };

    hardware = {
      bluetooth.enable = true;
      gpgSmartcards.enable = true;
      graphics = {
        enable = true;
        extraPackages = with pkgs; [
          intel-compute-runtime
          intel-media-driver
          intel-vaapi-driver
          libva-vdpau-driver
          libvdpau-va-gl
        ];
      };
    };

    i18n = {
      defaultLocale = "en_US.UTF-8";
      supportedLocales = [
        "en_US.UTF-8/UTF-8"
      ];
    };

    localServices.podman = {
      enable = true;
    };

    networking = {
      firewall = {
        allowedTCPPorts = [22];
        # allow the Tailscale UDP port through the firewall
        allowedUDPPorts = [config.services.tailscale.port];
        enable = true;
        # always allow traffic from your Tailscale network
        trustedInterfaces = ["tailscale0"];
      };
      hostName = "zw";
      nameservers = ["1.1.1.1"];
      wireless = {
        enable = true;
        networks = {
          "3216240371" = {
            pskRaw = "ext:HOME5536";
          };
          "Bonjour Bakery Cafe_5G" = {
            psk = "bakedgoods";
          };
          "Caje" = {
            psk = "cocktails";
          };
          "CatskillHouse" = {
            pskRaw = "ext:CATSKIPP_HOUSE";
          };
          "Conversations" = {
            psk = "hotchocolate";
          };
          "DeltaSkyClub" = {
            priority = 3;
          };
          "Feel love WiFi" = {
            psk = "namaste1";
          };
          "Hilton Honors" = {
            priority = 100;
          };
          "James Coffee_EXT" = {
            psk = "coffeecoffee";
          };
          "labarbacoffee" = {
            psk = "labarbadraper";
            priority = 100;
          };
          "Lannae" = {
            psk = "LannaeLove503";
          };
          "Magnus" = {
            pskRaw = "ext:MAGNUS";
          };
          "Manzanita Cafe" = {
            psk = "Manzanita2024";
          };
          Miniroam = {
            pskRaw = "ext:MINIROAM_PSK";
            priority = 99;
          };
          "MTShadows" = {
            psk = "WinterChills";
          };
          "MyOptimum c647cd" = {
            psk = "8328-emerald-20";
          };
          "RabbitHole" = {
            psk = "sunshine7";
          };
          "roam" = {
            pskRaw = "ext:ROAM_PSK";
            priority = 100;
          };
          "Sandy House Guest" = {
            pskRaw = "ext:SANDY";
          };
          "SURV-Guest100" = {
            pskRaw = "ext:SURV";
          };
          "tellmywifiiloveher" = {
            psk = "stegosaurus";
          };
          "TheCenturionLounge" = {
            priority = 4;
          };
          "VentureRV-57" = {
            pskRaw = "ext:VENTURE_RV";
          };
          "WGCR-2" = {
            psk = "Goose2010";
          };
        };
        secretsFile = config.age.secrets.wireless_networks.path;
        userControlled = true;
      };
    };

    nix = {
      # package = pkgs.lix;
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
      settings = {
        substituters = [
          "https://nix-community.cachix.org"
          "https://cache.nixos.org/"
        ];
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
        trusted-users = ["root" "adriano"];
        warn-dirty = false;
      };
    };

    programs = {
      dconf.enable = true;
      gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };
      i3lock = {
        enable = true;
        u2fSupport = true;
      };
      nh = {
        clean = {
          dates = "monthly";
          enable = true;
          extraArgs = "--delete-older-than 30d --keep 5";
        };
        enable = true;
        flake = "/home/adriano/git/nixos-system";
      };
      zsh.enable = true;
    };

    security = {
      pam = {
        services = {
          i3lock.u2fAuth = true;
          login.u2fAuth = true;
          sudo.u2fAuth = true;
        };
        u2f = {
          control = "sufficient"; # Yubikey is sufficient for authentication, no second factor required
          settings = {
            cue = true; # Show prompt when u2f is being requested, e.g. for sudo
          };
        };
        yubico = {
          debug = false;
          enable = true;
          id = ["24654932"];
          mode = "challenge-response";
        };
      };
      rtkit.enable = true;
    };

    services = {
      actkbd = {
        bindings = [
          {
            keys = [225];
            events = ["key"];
            command = "/run/current-system/sw/bin/brightnessctl set 10%+";
          }
          {
            keys = [224];
            events = ["key"];
            command = "/run/current-system/sw/bin/brightnessctl set 10%-";
          }
          {
            keys = [114];
            events = ["key"];
            command = "/run/current-system/sw/bin/runuser -l adriano -c 'wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-'";
          }
          {
            keys = [115];
            events = ["key"];
            command = "/run/current-system/sw/bin/runuser -l adriano -c 'wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+'";
          }
        ];
        enable = true;
      };
      blueman.enable = true;
      dbus.enable = true;
      displayManager = {
        defaultSession = "none+i3";
      };
      fprintd.enable = true;
      ivpn.enable = true;
      libinput = {
        enable = true;
        touchpad = {
          accelSpeed = "0.5";
          additionalOptions = ''
            Option "PalmDetection" "on"
          '';
          disableWhileTyping = true;
          naturalScrolling = true;
        };
      };
      openntpd.enable = true;
      openssh = {
        enable = true;
        settings.PasswordAuthentication = true;
      };
      pcscd.enable = true;
      pipewire = {
        alsa = {
          enable = true;
          support32Bit = true;
        };
        enable = true;
        pulse.enable = true;
        wireplumber.extraConfig."51-bluez-config" = {
          "monitor.bluez.properties" = {
            "bluez5.codecs" = ["ldac" "aptx_hd" "aptx" "aac" "sbc_xq" "sbc"];
            "bluez5.enable-hw-volume" = true;
            "bluez5.enable-msbc" = true;
            "bluez5.enable-sbc-xq" = true;
          };
        };
      };
      postgresql = {
        authentication = pkgs.lib.mkOverride 10 ''
          local all       all     trust
          # ipv4
          host  all      all     127.0.0.1/32   trust
          # ipv6
          host all       all     ::1/128        trust
        '';
        enable = false;
        enableTCPIP = true;
        ensureDatabases = ["neoq"];
        initialScript = pkgs.writeText "backend-initScript" ''
          CREATE ROLE postgres WITH LOGIN PASSWORD 'postres' CREATEDB;
          CREATE DATABASE neoq;
          GRANT ALL PRIVILEGES ON DATABASE neoq TO postgres;
          LOAD 'auto_explain';
        '';
        settings = {
          "auto_explain.log_analyze" = "true";
          "auto_explain.log_min_duration" = 0;
          "auto_explain.log_nested_statements" = "on";
          "auto_explain.log_triggers" = "true";
          client_min_messages = "LOG";
          log_connections = "yes";
          log_directory = "/tmp/";
          log_filename = "postgresql-%Y-%m-%d_%H%M%S.log";
          log_min_duration_statement = 0;
          log_min_error_statement = "DEBUG5";
          log_min_messages = "INFO";
          log_rotation_age = 1440;
          log_statement = "all";
          log_truncate_on_rotation = "true";
          logging_collector = "on";
          max_connections = 2000;
        };
      };
      tailscale = {
        authKeyFile = config.age.secrets.tailscale_key.path;
        enable = true;
      };
      udev = {
        # lock screen on unplug
        extraRules = ''
          ACTION=="remove",\
           ENV{ID_BUS}=="usb",\
           ENV{ID_MODEL_ID}=="0407",\
           ENV{ID_VENDOR_ID}=="1050",\
           ENV{ID_VENDOR}=="Yubico",\
           RUN+="${pkgs.systemd}/bin/loginctl lock-sessions"
        '';
        packages = [pkgs.yubikey-personalization];
      };
      xserver = {
        autoRepeatDelay = 250;
        autoRepeatInterval = 25;
        desktopManager = {
          xterm.enable = false;
        };
        enable = true;
        # Can't figure out how to enable natural scrolling. Ideally what I want is natural scrolling AND palm detection,
        # but for now, it seems like I can't have both without getting my hands more dirty. Switching back to libinput
        synaptics = {
          accelFactor = "0.01";
          enable = false;
          maxSpeed = "2.0";
          palmDetect = true;
          twoFingerScroll = true;
        };
        windowManager.i3.enable = true;
        xkb = {
          layout = "us";
          options = "caps:ctrl_modifier";
        };
      };
    };

    substituters.private.enable = true;

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It's perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "23.05"; # Did you read the comment?

    systemd = {
      services = {
        address-book-sync = {
          description = "Syncs the Fastmail address book";
          enable = true;
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
          serviceConfig = {
            Type = "oneshot";
            User = "adriano";
          };
        };
        khal-notify = {
          description = "Calendar notification with i3-nagbar";
          enable = true;
          environment = {
            DISPLAY = ":0";
          };
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
          serviceConfig = {
            Type = "simple";
            User = "adriano";
          };
        };
      };
      timers = {
        address-book-sync = {
          partOf = ["address-book-sync.service"];
          timerConfig = {
            OnCalendar = "*-*-* 00:00:00";
          };
          wantedBy = ["timers.target"];
        };
      };
    };

    time.timeZone = "America/Denver";

    users = {
      extraGroups.vboxusers.members = ["adriano"];
      mutableUsers = true;
      users.adriano = {
        extraGroups = ["wheel" "networkmanager" "docker" "wpa_supplicant" "video"];
        isNormalUser = true;
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
            brightnessctl
            chatgpt-cli
            clipmenu
            ctags
            dante
            dict
            dig
            di-tui
            direnv
            dmenu
            docker
            fprintd
            fzf
            gimp
            git
            glow
            gnumake
            go
            golangci-lint
            golangci-lint-langserver
            gopass
            gopass-jsonapi
            gopls
            gscreenshot
            hugo
            icdiff
            inetutils
            ivpn
            jq
            kitty
            lazygit
            libreoffice
            logseq
            ltex-ls
            ncdu
            nil
            nix-index
            nodejs
            nomad_1_9
            nushell
            opentofu
            pandoc
            playerctl
            python3
            python311Packages.sqlparse
            qrencode
            ripgrep
            rofi
            shutter
            simplescreenrecorder
            slack
            speedtest-cli
            spotify-player
            stripe-cli
            tailscale
            taplo
            terraform
            terraform-lsp
            tmux
            tree
            typescript-language-server
            ungoogled-chromium
            unzip
            usbutils
            vlc
            vscode-langservers-extracted
            w3m
            weechat
            widevine-cdm
            wpa_supplicant_gui
            xclip
            xsel
            yubikey-manager
            zeal
            zoom-us
          ];
        password = "Iliketochangeitchangeit";
        shell = pkgs.zsh;
      };
    };

    virtualisation = {
      docker.enable = true;
      virtualbox.host = {
        addNetworkInterface = false;
        enable = false;
        enableKvm = true;
      };
    };
  };
}
