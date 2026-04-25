{
  config,
  pkgs,
  lib,
  kitty-grab,
  agenix,
  ...
}: {
  imports = [
    ../../../common/accounts/calendars.nix
    ../../../common/applications/run-in-zellij.nix
    ../../../common/home-manager/ai-agents
    ../../../common/home-manager/helix
    ../../../common/home-manager/jira
    ../../../common/home-manager/qutebrowser
    ../../../common/home-manager/zellij
    agenix.homeManagerModules.default
  ];

  accounts = {
    calendar.accounts = {
      fastmail.remote.passwordCommand = ["${pkgs.gopass}/bin/gopass" "show" "-o" "fastmail.com/me-aerc"];
    };
    email = {
      maildirBasePath = "/home/adriano/.mail";
      accounts = {
        Personal = {
          address = "me@adriano.fyi";
          aerc = {
            enable = true;
            # extraAccounts = {
            #   source = "notmuch:///home/adriano/.mail";
            #   maildir-store = "/home/adriano/.mail/Personal";
            #   query-map = "/home/adriano/.config/notmuch/querymap-personal";
            # };
          };
          gpg = {
            encryptByDefault = true;
            key = "C2BC56DE73CE3F75!";
            signByDefault = true;
          };
          imap.host = "imap.fastmail.com";
          mbsync = {
            create = "both";
            enable = true;
            expunge = "both";
            remove = "both";
          };
          msmtp.enable = true;
          notmuch.enable = true;
          passwordCommand = "${pkgs.gopass}/bin/gopass show -o fastmail.com/me-aerc";
          primary = true;
          realName = "Adriano Caloiaro";
          smtp.host = "smtp.fastmail.com";
          userName = "me@adriano.fyi";
        };

        Zenity = {
          address = "adriano@zenitylabs.com";
          aerc = {
            enable = true;
            # extraAccounts = {
            #   source = "notmuch:///home/adriano/.mail";
            #   maildir-store = "/home/adriano/.mail/Zenity";
            #   query-map = "/home/adriano/.config/notmuch/querymap-zenity";
            # };
          };
          imap.host = "imap.fastmail.com";
          mbsync = {
            create = "both";
            enable = true;
            expunge = "both";
            remove = "both";
          };
          msmtp.enable = true;
          notmuch.enable = true;
          passwordCommand = "${pkgs.gopass}/bin/gopass show -o fastmail.com/zenity-aerc";
          primary = false;
          realName = "Adriano Caloiaro";
          smtp.host = "smtp.fastmail.com";
          userName = "adriano@zenitylabs.com";
        };
      };
    };
  };

  age = {
    identityPaths = ["/home/adriano/.ssh/id_rsa_agenix"];
    rekey = {
      hostPubkey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCx/tvR11RUMbYaauuHPxR3j79vm1Hxg+Y3LXR+rLgZ7N/2ulvIzLLZgVuIUbmJHDqkp9Au5zZPMZjsKbaqQ8V75wSEcyaSMbaxC9PaNDCwEHMJWaz8XPQe5IjVRE5O+4sTyh7ZBx+NMQmPcQbrNInoKuy4EjFmwTW/t0xYo/sCrC0NX0cCyeBwii2JdFXytXfxF+RMzGNXw1xfcOFJe6F7JdS/Cpf/0fe+VmNg8d0nic4Obcb/djYsRLAAC6Cvb+4i3EBZWl+9Ih9hId8bFCRKhI6TmGT2z4YUTa+v+3j/JZUh1gD5n4vRGf8QjLj9N6DrBnKcbywwqyqnLhTLgBBN35rcLdU1k3n0NorRRDCU0Lg/ejsFe3oi2FmOwNmmd8zqBNZHjJTi5Wy63EXMFwHltEY2M+hAhgWsQ5U4zuVPgv1HfD6LYPodRwhdZivwTNr2IClAiVVxR//O0WtrRXrrEM5uudj+Y30/ah7bn9Mje86UV0TqfS2tdjtMkySHL+M= adriano@z1";
      localStorageDir = ./. + "/secrets/rekeyed/";
    };
    secrets = {
      "opencode-context7-api-key" = {
        mode = "400";
        rekeyFile = ../../../common/secrets/opencode-context7-api-key.age;
      };
      "opencode-github-mcp-pat" = {
        mode = "400";
        rekeyFile = ../../../common/secrets/opencode-github-mcp-pat.age;
      };
    };
  };

  ai-agents = {
    claude-code = {
      enable = true;
      enabledPlugins = {
        "lsp-mux-go-nix@lsp-mux" = true;
        "lsp-mux-nix-nix@lsp-mux" = true;
        "lsp-mux-python@lsp-mux" = true;
      };
      marketplaces = {
        jcmuller-plugins = {
          url = "https://git.sr.ht/~jcmuller/claude-plugins";
        };
        lsp-mux = {
          url = "https://git.sr.ht/~jcmuller/lsp-mux";
        };
      };
      settings = {
        hooks = {
          PreToolUse = [
            {
              matcher = "Edit|Write";
              hooks = [
                {
                  type = "command";
                  command = "run-in-zellij -- hookable --interactive --no-exit-code --cmd '${lib.getExe pkgs.adiff} -i'";
                }
              ];
            }
          ];
        };

        # hooks = {
        # PostToolUse = [
        #   {
        #     matcher = "Bash";
        #     "if" = "Bash(jj *)";
        #     hooks = [
        #       {
        #         type = "command";
        #         command = "ctxrl --hook";
        #       }
        #     ];
        #   }
        # ];
        # };
      };
    };
    enable = true;
    mcp = {
      atlassian.enable = false;
      context7 = {
        enable = true;
        patPath = config.age.secrets."opencode-context7-api-key".path;
      };
      github.patPath = config.age.secrets.opencode-github-mcp-pat.path;
      glean.enable = false;
    };
  };

  home = {
    activation.install-dictionaries = lib.hm.dag.entryAfter ["writeBoundary"] ''
      ${pkgs.qutebrowser}/share/qutebrowser/scripts/dictcli.py install en-US
    '';
    file = {
      ".config/gopass" = {
        recursive = true;
        source = ./gopass;
      };
      ".config/nix" = {
        recursive = true;
        source = ./nix;
      };
      ".mozilla/native-messaging-hosts/com.justwatch.gopass.json".source = ./gopass/gopass-api-manifest.json;
      "${config.xdg.configHome}/aerc/binds.conf".source = ./aerc/binds.conf;
      "${config.xdg.configHome}/kitty/grab.conf".source = ./kitty/kitty_grab.conf;
      "${config.xdg.configHome}/kitty/kitty_grab" = {
        recursive = true;
        source = kitty-grab;
      };
      "${config.xdg.configHome}/mbsync/postExec" = {
        executable = true;
        text = ''
          #!${pkgs.stdenv.shell}
          ${pkgs.notmuch}/bin/notmuch new
        '';
      };
      "${config.xdg.configHome}/notmuch/querymap-personal".source = ./notmuch/querymap-personal;
      "${config.xdg.configHome}/notmuch/querymap-zenity".source = ./notmuch/querymap-zenity;
    };
    homeDirectory = "/home/adriano";
    packages = with pkgs; [
      adiff
      age
      btsw
      gnome-keyring
      hookable
      opencloud-desktop
      pinentry-rofi
      (symlinkJoin {
        name = "pinentry-wrapper";
        paths = [pinentry-rofi];
        postBuild = ''
          mkdir -p $out/bin
          ln -s ${pinentry-rofi}/bin/pinentry-rofi $out/bin/pinentry
        '';
      })
      prettier
      yazi
      zeal
      zsh
    ];
    sessionVariables = {
      "GO111MODULE" = "on";
      "PATH" = "$HOME/.local/bin:$PATH:/home/adriano/go/bin:$HOME/.nix-profile/bin";
      "PINENTRY" = "${pkgs.pinentry-rofi}/bin/pinentry-rofi";
      "SHELL" = "/run/current-system/sw/bin/zsh";
    };
    stateVersion = "23.05";
    username = "adriano";
  };

  modules.zellij = {
    autoLayout = true;
    autoStart = true;
    enable = true;
    paneFrames = false;
    sessionSerialization = true;
    theme = "nord";
  };

  programs = {
    aerc = {
      enable = true;
      extraConfig = {
        compose = {
          address-book-cmd = ''${pkgs.abook}/bin/abook --mutt-query "%s"'';
        };
        filters = {
          "message/delivery-status" = "colorize";
          "message/rfc822" = "colorize";
          "text/calendar" = "calendar";
          "text/html" = "cat";
          "text/plain" = "colorize";
        };
        general = {
          file-picker-cmd = ''${pkgs.fzf}/bin/fzf --multi --query=%s'';
          log-file = "/tmp/aerc.log";
          log-level = "trace";
          unsafe-accounts-conf = true;
        };
        hooks = {
          mail-received = ''dunstify "New email from $AERC_FROM_NAME" "$AERC_SUBJECT"'';
        };
        ui = {
          sidebar-width = 25;
          spinner = "[ ⡿ ],[ ⣟ ],[ ⣯ ],[ ⣷ ],[ ⣾ ],[ ⣽ ],[ ⣻ ],[ ⢿ ]";
          this-day-time-format = ''"           15:04"'';
          this-year-time-format = "Mon Jan 02 15:04";
          timestamp-format = "2006-01-02 15:04";
        };
        viewer = {
          alternatives = "text/html,text/plain";
          pager = "cha -T 'text/html'";
        };
      };
    };
    atuin = {
      daemon = {
        enable = true;
      };
      enable = true;
      enableZshIntegration = true;
      flags = ["--disable-up-arrow"];
      settings = {
        enter_accept = false;
      };
    };
    chawan = {
      enable = true;
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    firefox = {
      enable = true;
      package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
        extraPolicies = {
          CaptivePortal = false;
          DisableFirefoxAccounts = false;
          DisableFirefoxStudies = true;
          DisablePocket = true;
          DisableTelemetry = true;
          FirefoxHome = {
            Highlights = false;
            Pocket = false;
            Search = true;
            Snippets = false;
            TopSites = false;
          };
          NoDefaultBookmarks = true;
          OfferToSaveLogins = false;
          OfferToSaveLoginsDefault = false;
          PasswordManagerEnabled = false;
          UserMessaging = {
            ExtensionRecommendations = false;
            SkipOnboarding = true;
          };
        };
      };
      profiles = {
        adriano = {
          extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
            floccus
            gopass-bridge
            noscript
            tridactyl
            ublock-origin
          ];
          id = 0;
          name = "adriano";
        };
      };
    };
    home-manager = {
      enable = true;
    };
    i3status-rust = {
      bars = {
        bottom = {
          blocks = [
            {
              block = "net";
              format = " {$signal_strength $ssid $frequency|} $device $icon  ^icon_net_down $speed_down.eng(prefix:K) ^icon_net_up $speed_up.eng(prefix:K)";
              interval = 5;
            }
            {
              block = "memory";
              interval = 5;
            }
            {
              block = "cpu";
              interval = 5;
            }
            {
              block = "sound";
            }
            {
              block = "battery";
            }
          ];
          icons = "awesome5";
          theme = "nord-dark";
        };
        top = {
          blocks = [
            {
              block = "custom";
              command = "curl -s https://jellybee.bison-lizard.ts.net/whereami | jq -r '\"\\(.conditions.emoji // \"\") \\(.conditions.label // \"\")  \\(.location.name // \"?\")  \\(.weather.tempf // \"?\")°F  \\(.weather.humidity // \"?\")%  💨 \\(.weather.windspeedmph // \"?\")mph\"'";
              interval = 60;
            }
            {
              block = "time";
              format = "$timestamp.datetime(f:'%Z %R') ";
              interval = 60;
              timezone = "UTC";
            }
            {
              block = "time";
              format = "$timestamp.datetime(f:'%Z %R') ";
              interval = 60;
              timezone = "America/New_York";
            }
            {
              block = "time";
              format = "$timestamp.datetime(f:'%Z %R %d/%m ') ";
              interval = 60;
            }
          ];
          icons = "awesome5";
          theme = "nord-dark";
        };
      };
      enable = true;
    };
    kitty = {
      enable = true;
      extraConfig = ''
        # enabled_layouts fat,tall,stack
        enabled_layouts tall:bias=50;full_size=1;mirrored=false
        map Alt+g kitten         kitty_grab/grab.py
        map Ctrl+Shift+h         previous_tab
        map Ctrl+Shift+l         next_tab
        map Ctrl+Shift+b         show_scrollback
        map Ctrl+Shift+p         goto_layout fat
        draw_minimal_borders     yes
        window_padding_width     2
        window_border_width      0
        hide_window_decorations  yes
        titlebar-only            yes
        active_border_color      none
        font_size                13.8
      '';
      shellIntegration.enableZshIntegration = true;
      themeFile = "GitHub_Dark_Dimmed"; # For normal/lower light environments
      # themeFile = "GitHub_Light"; # For higher light environments
    };
    lsp-mux = {
      # Global settings (inherited by all profiles unless overridden).
      degradationThreshold = 3;
      enable = true;
      logFile = "/tmp/lsp-mux.log";
      logLevel = "info";
      profiles = {
        go.enable = true;
        nix.enable = true;
      };
      requestTimeout = "10s";
    };
    mbsync.enable = true;
    msmtp.enable = true;
    notmuch = {
      enable = true;
      hooks.postNew = ''
        ${pkgs.notmuch}/bin/notmuch tag +personal -- tag:new and folder:/Personal/
        ${pkgs.notmuch}/bin/notmuch tag +zenity -- tag:new and folder:/Zenity/
      '';
      new.tags = ["new" "inbox"];
    };
    qutebrowser.settings = {
      fonts.default_size = lib.mkForce "18px";
      zoom.default = "138%";
    };
    starship = {
      enable = true;
      enableZshIntegration = true;
    };
    zsh = {
      autosuggestion.enable = true;
      dotDir = config.home.homeDirectory;
      enable = true;
      enableCompletion = true;
      initContent = lib.mkBefore ''
        # Start gnome-keyring daemon if not already running (for i3/wm users)
        if [ -z "$GNOME_KEYRING_CONTROL" ]; then
          dbus-update-activation-environment --all
          eval "$(gnome-keyring-daemon --start --components=secrets)"
        fi
      '';
      shellAliases = {
        addresses = "hx ~/KB/pages/Important\\ Addresses.md";
        gpgen = "gopass generate \"$1/$1@adriano.fyi\"";
        ideas = "hx ~/KB/pages/Notes/ideas/";
        ll = "ls -l";
        ncm-token = "${pkgs.gopass}/bin/gopass show ncm | grep Secret | awk '{print \$4}'";
        nomad = "NOMAD_ADDR=http://ncm-3:4646 NOMAD_TOKEN=$(gopass show systems/ncm | grep \"Secret ID\" | awk '{print $4}') nomad $*";
        notes = "hx ~/KB";
        open = "xdg-open $*";
        people = "vim ~/KB/pages/People.md";
        quickqr = "qrencode -t ansiutf8 $*";
        vi = "hx $*";
        vim = "hx $*";
      };
      syntaxHighlighting.enable = true;
    };
  };

  services = {
    dunst.enable = true;
    gnome-keyring = {
      components = ["pkcs11" "secrets"]; # secrets provides D-Bus Secret Service
      enable = true;
    };
    gpg-agent = {
      defaultCacheTtl = 60 * 60 * 24;
      defaultCacheTtlSsh = 60 * 60 * 24;
      enable = true;
      enableNushellIntegration = true;
      enableScDaemon = true;
      enableSshSupport = true;
      maxCacheTtl = 60 * 60 * 24;
    };
    mbsync = {
      enable = true;
      postExec = "${config.xdg.configHome}/mbsync/postExec";
    };
    screen-locker = {
      enable = true;
      inactiveInterval = 30;
      lockCmd = "${pkgs.i3lock}/bin/i3lock -n -c 000000";
      xautolock = {
        detectSleep = true;
        enable = true;
      };
    };
    vdirsyncer.enable = true;
  };

  xdg = {
    autostart.enable = true;
    enable = true;
    mime.enable = true;
    mimeApps = {
      defaultApplications = let
        browser = "org.qutebrowser.qutebrowser.desktop";
      in {
        "text/html" = browser;
        "x-scheme-handler/about" = browser;
        "x-scheme-handler/http" = browser;
        "x-scheme-handler/https" = browser;
        "x-scheme-handler/logseq" = "Logseq.desktop";
        "x-scheme-handler/slack" = "Slack.desktop";
        "x-scheme-handler/unknown" = browser;
      };
      enable = true;
    };
  };

  xsession.windowManager.i3 = {
    config = rec {
      modifier = "Mod4";
      assigns = {
        "1" = [{class = "^qutebrowser$";}];
        "2" = [{class = "^kitty$";}];
        "3" = [{class = "^Beeper$";}];
        "4" = [{class = "^Logseq$";}];
        "6" = [{class = "^Slack$";}];
      };
      bars = [
        {
          fonts = {
            names = ["DejaVu Sans Mono" "FontAwesome5Free"];
            size = 12.0;
            style = "Bold Semi-Condensed";
          };
          mode = "hide";
          position = "bottom";
          statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ~/.config/i3status-rust/config-bottom.toml";
          trayOutput = "primary";
        }
        {
          fonts = {
            names = ["DejaVu Sans Mono" "FontAwesome5Free"];
            size = 12.0;
            style = "Bold Semi-Condensed";
          };
          mode = "hide";
          position = "top";
          statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ~/.config/i3status-rust/config-top.toml";
          trayOutput = "primary";
        }
      ];
      gaps = {
        inner = 3;
        outer = 1;
      };
      keybindings = lib.mkOptionDefault {
        # Move
        "${modifier}+Shift+h" = "move left";
        "${modifier}+Shift+j" = "move down";
        "${modifier}+Shift+k" = "move up";
        "${modifier}+Shift+l" = "move right";
        # Focus
        "${modifier}+h" = "focus left";
        "${modifier}+j" = "focus down";
        "${modifier}+k" = "focus up";
        "${modifier}+l" = "focus right";
        "${modifier}+Return" = "exec ${pkgs.kitty}/bin/kitty --shell /run/current-system/sw/bin/zsh";
        "${modifier}+Shift+d" = "exec ${pkgs.rofi}/bin/rofi -show window";
        "${modifier}+Shift+x" = "exec systemctl suspend";
        "${modifier}+d" = "exec ${pkgs.rofi}/bin/rofi -modi drun -show drun";
        "Cancel" = "exec playerctl stop";
        "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 4%-";
        "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        "XF86AudioPause" = "exec playerctl play-pause";
        "XF86AudioPlay" = "exec playerctl play-pause";
        "XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 4%+";
        "XF86Display" = "exec xrandr --output DP-1 --mode 1920x1080 --left-of eDP-1 --auto";
        "XF86Go" = "exec playerctl play";
        "XF86MonBrightnessDown" = "exec brightnessctl set 4%-";
        "XF86MonBrightnessUp" = "exec brightnessctl set 4%+";
      };
      startup = [
        {
          always = true;
          command = "qutebrowser";
          notification = false;
        }
        {
          always = true;
          command = "kitty";
          notification = false;
        }
        {
          always = true;
          command = "beeper";
          notification = false;
        }
        {
          always = true;
          command = "logseq";
          notification = false;
        }
      ];
      window = {
        border = 0;
        titlebar = false;
      };
      workspaceAutoBackAndForth = true;
      workspaceOutputAssign = [
        {
          output = "eDP-1";
          workspace = "1";
        }
        {
          output = "eDP-1";
          workspace = "2";
        }
        {
          output = "eDP-1";
          workspace = "3";
        }
        {
          output = "eDP-1";
          workspace = "4";
        }
        {
          output = "eDP-1";
          workspace = "5";
        }
        {
          output = "DP-1";
          workspace = "6";
        }
        {
          output = "DP-1";
          workspace = "7";
        }
        {
          output = "DP-1";
          workspace = "8";
        }
        {
          output = "DP-1";
          workspace = "9";
        }
      ];
    };
    enable = true;
    package = pkgs.i3;
  };
}
