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

  age = {
    identityPaths = ["/home/adriano/.ssh/id_rsa_agenix"];
    rekey = {
      hostPubkey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCx/tvR11RUMbYaauuHPxR3j79vm1Hxg+Y3LXR+rLgZ7N/2ulvIzLLZgVuIUbmJHDqkp9Au5zZPMZjsKbaqQ8V75wSEcyaSMbaxC9PaNDCwEHMJWaz8XPQe5IjVRE5O+4sTyh7ZBx+NMQmPcQbrNInoKuy4EjFmwTW/t0xYo/sCrC0NX0cCyeBwii2JdFXytXfxF+RMzGNXw1xfcOFJe6F7JdS/Cpf/0fe+VmNg8d0nic4Obcb/djYsRLAAC6Cvb+4i3EBZWl+9Ih9hId8bFCRKhI6TmGT2z4YUTa+v+3j/JZUh1gD5n4vRGf8QjLj9N6DrBnKcbywwqyqnLhTLgBBN35rcLdU1k3n0NorRRDCU0Lg/ejsFe3oi2FmOwNmmd8zqBNZHjJTi5Wy63EXMFwHltEY2M+hAhgWsQ5U4zuVPgv1HfD6LYPodRwhdZivwTNr2IClAiVVxR//O0WtrRXrrEM5uudj+Y30/ah7bn9Mje86UV0TqfS2tdjtMkySHL+M= adriano@z1";
      localStorageDir = ./. + "/secrets/rekeyed/";
    };

    secrets = {
      "opencode-github-mcp-pat" = {
        rekeyFile = ../../../common/secrets/opencode-github-mcp-pat.age;
        mode = "400";
      };

      "opencode-context7-api-key" = {
        rekeyFile = ../../../common/secrets/opencode-context7-api-key.age;
        mode = "400";
      };
    };
  };

  programs.home-manager = {
    enable = true;
  };
  home = {
    stateVersion = "23.05";
    sessionVariables = {
      "GO111MODULE" = "on";
      "PATH" = "$HOME/.local/bin:$PATH:/home/adriano/go/bin:$HOME/.nix-profile/bin";
      "PINENTRY" = "${pkgs.pinentry-rofi}/bin/pinentry-rofi";
      "SHELL" = "/run/current-system/sw/bin/zsh";
    };
    username = "adriano";
    homeDirectory = "/home/adriano";
    activation.install-dictionaries = lib.hm.dag.entryAfter ["writeBoundary"] ''
      ${pkgs.qutebrowser}/share/qutebrowser/scripts/dictcli.py install en-US
    '';
    packages = with pkgs; [
      age
      btsw
      hookable
      gnome-keyring
      prettier
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
      yazi
      zeal
      zsh
    ];
    file = {
      ".mozilla/native-messaging-hosts/com.justwatch.gopass.json".source = ./gopass/gopass-api-manifest.json;
      ".config/gopass" = {
        source = ./gopass;
        recursive = true;
      };
      ".config/nix" = {
        source = ./nix;
        recursive = true;
      };
      "${config.xdg.configHome}/kitty/kitty_grab" = {
        source = kitty-grab;
        recursive = true;
      };
      "${config.xdg.configHome}/kitty/grab.conf".source = ./kitty/kitty_grab.conf;
      "${config.xdg.configHome}/notmuch/querymap-personal".source = ./notmuch/querymap-personal;
      "${config.xdg.configHome}/notmuch/querymap-zenity".source = ./notmuch/querymap-zenity;
      "${config.xdg.configHome}/aerc/binds.conf".source = ./aerc/binds.conf;
      "${config.xdg.configHome}/mbsync/postExec" = {
        text = ''
          #!${pkgs.stdenv.shell}
          ${pkgs.notmuch}/bin/notmuch new
        '';
        executable = true;
      };
    };
  };

  services.dunst.enable = true;
  services.screen-locker = {
    enable = true;
    inactiveInterval = 30;
    lockCmd = "${pkgs.i3lock}/bin/i3lock -n -c 000000";
    xautolock = {
      enable = true;
      detectSleep = true;
    };
  };

  services.mbsync = {
    enable = true;
    postExec = "${config.xdg.configHome}/mbsync/postExec";
  };

  services.vdirsyncer.enable = true;

  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3;

    config = rec {
      modifier = "Mod4";
      bars = [
        {
          trayOutput = "primary";
          position = "bottom";
          mode = "hide";
          statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ~/.config/i3status-rust/config-bottom.toml";
          fonts = {
            names = ["DejaVu Sans Mono" "FontAwesome5Free"];
            style = "Bold Semi-Condensed";
            size = 12.0;
          };
        }
        {
          trayOutput = "primary";
          position = "top";
          mode = "hide";
          statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ~/.config/i3status-rust/config-top.toml";
          fonts = {
            names = ["DejaVu Sans Mono" "FontAwesome5Free"];
            style = "Bold Semi-Condensed";
            size = 12.0;
          };
        }
      ];

      workspaceAutoBackAndForth = true;
      window.border = 0;
      window.titlebar = false;

      workspaceOutputAssign = [
        {
          workspace = "1";
          output = "eDP-1";
        }
        {
          workspace = "2";
          output = "eDP-1";
        }
        {
          workspace = "3";
          output = "eDP-1";
        }
        {
          workspace = "4";
          output = "eDP-1";
        }
        {
          workspace = "5";
          output = "eDP-1";
        }
        {
          workspace = "6";
          output = "DP-1";
        }
        {
          workspace = "7";
          output = "DP-1";
        }
        {
          workspace = "8";
          output = "DP-1";
        }
        {
          workspace = "9";
          output = "DP-1";
        }
      ];

      gaps = {
        inner = 3;
        outer = 1;
      };

      keybindings = lib.mkOptionDefault {
        "XF86Go" = "exec playerctl play";
        "Cancel" = "exec playerctl stop";
        "XF86AudioPlay" = "exec playerctl play-pause";
        "XF86AudioPause" = "exec playerctl play-pause";
        "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 4%-";
        "XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 4%+";
        "XF86MonBrightnessDown" = "exec brightnessctl set 4%-";
        "XF86MonBrightnessUp" = "exec brightnessctl set 4%+";
        "${modifier}+Return" = "exec ${pkgs.kitty}/bin/kitty --shell /run/current-system/sw/bin/zsh";
        "${modifier}+d" = "exec ${pkgs.rofi}/bin/rofi -modi drun -show drun";
        "${modifier}+Shift+d" = "exec ${pkgs.rofi}/bin/rofi -show window";
        "${modifier}+Shift+x" = "exec systemctl suspend";
        # Move
        "${modifier}+Shift+h" = "move left";
        "${modifier}+Shift+l" = "move right";
        "${modifier}+Shift+k" = "move up";
        "${modifier}+Shift+j" = "move down";
        # Focus
        "${modifier}+h" = "focus left";
        "${modifier}+l" = "focus right";
        "${modifier}+j" = "focus down";
        "${modifier}+k" = "focus up";

        "XF86Display" = "exec xrandr --output DP-1 --mode 1920x1080 --left-of eDP-1 --auto";
      };
      assigns = {
        "1" = [{class = "^qutebrowser$";}];
        "2" = [{class = "^kitty$";}];
        "3" = [{class = "^Beeper$";}];
        "4" = [{class = "^Logseq$";}];
        "6" = [{class = "^Slack$";}];
      };
      startup = [
        {
          command = "qutebrowser";
          always = true;
          notification = false;
        }
        {
          command = "kitty";
          always = true;
          notification = false;
        }
        {
          command = "beeper";
          always = true;
          notification = false;
        }
        {
          command = "logseq";
          always = true;
          notification = false;
        }
      ];
    };
  };

  programs.i3status-rust = {
    enable = true;
    bars = {
      top = {
        blocks = [
          {
            block = "custom";
            command = "curl -s https://jellybee.bison-lizard.ts.net/whereami | jq -r '\"\\(.conditions.emoji // \"\") \\(.conditions.label // \"\")  \\(.location.name // \"?\")  \\(.weather.tempf // \"?\")°F  \\(.weather.humidity // \"?\")%  💨 \\(.weather.windspeedmph // \"?\")mph\"'";
            interval = 60;
          }
          {
            block = "time";
            interval = 60;
            timezone = "UTC";
            format = "$timestamp.datetime(f:'%Z %R') ";
          }
          {
            block = "time";
            interval = 60;
            timezone = "America/New_York";
            format = "$timestamp.datetime(f:'%Z %R') ";
          }
          {
            block = "time";
            interval = 60;
            format = "$timestamp.datetime(f:'%Z %R %d/%m ') ";
          }
        ];
        icons = "awesome5";
        theme = "nord-dark";
      };
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
    };
  };

  programs.kitty = {
    enable = true;
    themeFile = "GitHub_Dark_Dimmed"; # For normal/lower light environments
    # themeFile = "GitHub_Light"; # For higher light environments
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
  };
  programs.lsp-mux = {
    enable = true;

    # Global settings (inherited by all profiles unless overridden).
    logFile = "/tmp/lsp-mux.log";
    logLevel = "info";
    requestTimeout = "10s";
    degradationThreshold = 3;

    profiles = {
      go.enable = true;
      nix.enable = true;
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    dotDir = config.home.homeDirectory;
    initContent = lib.mkBefore ''
      # Start gnome-keyring daemon if not already running (for i3/wm users)
      if [ -z "$GNOME_KEYRING_CONTROL" ]; then
        dbus-update-activation-environment --all
        eval "$(gnome-keyring-daemon --start --components=secrets)"
      fi
    '';
    shellAliases = {
      addresses = "hx ~/KB/pages/Important\\ Addresses.md";
      ideas = "hx ~/KB/pages/Notes/ideas/";
      people = "vim ~/KB/pages/People.md";
      notes = "hx ~/KB";
      open = "xdg-open $*";
      quickqr = "qrencode -t ansiutf8 $*";
      gpgen = "gopass generate \"$1/$1@adriano.fyi\"";
      ll = "ls -l";
      vi = "hx $*";
      vim = "hx $*";
      ncm-token = "${pkgs.gopass}/bin/gopass show ncm | grep Secret | awk '{print \$4}'";
      nomad = "NOMAD_ADDR=http://ncm-3:4646 NOMAD_TOKEN=$(gopass show systems/ncm | grep \"Secret ID\" | awk '{print $4}') nomad $*";
    };
  };

  modules.zellij = {
    enable = true;
    theme = "nord";
    sessionSerialization = true;
    autoLayout = true;
    paneFrames = false;
    autoStart = true;
  };

  programs.atuin = {
    enable = true;
    daemon = {
      enable = true;
    };
    enableZshIntegration = true;
    settings = {
      enter_accept = false;
    };
    flags = ["--disable-up-arrow"];
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableNushellIntegration = true;
    enableScDaemon = true;

    maxCacheTtl = 60 * 60 * 24;
    defaultCacheTtl = 60 * 60 * 24;
    defaultCacheTtlSsh = 60 * 60 * 24;
  };
  services.gnome-keyring = {
    enable = true;
    components = ["pkcs11" "secrets"]; # secrets provides D-Bus Secret Service
  };

  xdg.autostart.enable = true; # Enable creation of XDG autostart entries.
  programs.firefox = {
    enable = true;
    package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
      extraPolicies = {
        CaptivePortal = false;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableTelemetry = true;
        DisableFirefoxAccounts = false;
        NoDefaultBookmarks = true;
        OfferToSaveLogins = false;
        OfferToSaveLoginsDefault = false;
        PasswordManagerEnabled = false;
        FirefoxHome = {
          Search = true;
          Pocket = false;
          Snippets = false;
          TopSites = false;
          Highlights = false;
        };
        UserMessaging = {
          ExtensionRecommendations = false;
          SkipOnboarding = true;
        };
      };
    };

    profiles = {
      adriano = {
        id = 0;
        name = "adriano";
        extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
          floccus
          ublock-origin
          gopass-bridge
          tridactyl
          noscript
        ];
      };
    };
  };

  programs.chawan = {
    enable = true;
  };

  programs.aerc = {
    enable = true;
    extraConfig = {
      general = {
        file-picker-cmd = ''${pkgs.fzf}/bin/fzf --multi --query=%s'';
        unsafe-accounts-conf = true;
        log-level = "trace";
        log-file = "/tmp/aerc.log";
      };

      compose = {
        address-book-cmd = ''${pkgs.abook}/bin/abook --mutt-query "%s"'';
      };

      ui = {
        this-day-time-format = ''"           15:04"'';
        this-year-time-format = "Mon Jan 02 15:04";
        timestamp-format = "2006-01-02 15:04";
        spinner = "[ ⡿ ],[ ⣟ ],[ ⣯ ],[ ⣷ ],[ ⣾ ],[ ⣽ ],[ ⣻ ],[ ⢿ ]";
        sidebar-width = 25;
      };

      viewer = {
        alternatives = "text/html,text/plain";
        pager = "cha -T 'text/html'";
      };

      filters = {
        "text/plain" = "colorize";
        "text/html" = "cat";
        "text/calendar" = "calendar";
        "message/delivery-status" = "colorize";
        "message/rfc822" = "colorize";
      };

      hooks = {
        mail-received = ''dunstify "New email from $AERC_FROM_NAME" "$AERC_SUBJECT"'';
      };
    };
  };
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.mbsync.enable = true;
  programs.msmtp.enable = true;
  programs.notmuch = {
    enable = true;
    new.tags = ["new" "inbox"];
    hooks.postNew = ''
      ${pkgs.notmuch}/bin/notmuch tag +personal -- tag:new and folder:/Personal/
      ${pkgs.notmuch}/bin/notmuch tag +zenity -- tag:new and folder:/Zenity/
    '';
  };

  accounts = {
    email = {
      maildirBasePath = "/home/adriano/.mail";
      accounts = {
        Personal = {
          primary = true;
          aerc = {
            enable = true;
            # extraAccounts = {
            #   source = "notmuch:///home/adriano/.mail";
            #   maildir-store = "/home/adriano/.mail/Personal";
            #   query-map = "/home/adriano/.config/notmuch/querymap-personal";
            # };
          };
          realName = "Adriano Caloiaro";
          address = "me@adriano.fyi";
          imap.host = "imap.fastmail.com";
          smtp.host = "smtp.fastmail.com";
          userName = "me@adriano.fyi";
          passwordCommand = "${pkgs.gopass}/bin/gopass show -o fastmail.com/me-aerc";

          mbsync = {
            enable = true;
            create = "both";
            expunge = "both";
            remove = "both";
          };
          msmtp.enable = true;
          notmuch.enable = true;

          gpg = {
            encryptByDefault = true;
            signByDefault = true;
            key = "C2BC56DE73CE3F75!";
          };
        };

        Zenity = {
          primary = false;
          aerc = {
            enable = true;
            # extraAccounts = {
            #   source = "notmuch:///home/adriano/.mail";
            #   maildir-store = "/home/adriano/.mail/Zenity";
            #   query-map = "/home/adriano/.config/notmuch/querymap-zenity";
            # };
          };
          realName = "Adriano Caloiaro";
          address = "adriano@zenitylabs.com";
          imap.host = "imap.fastmail.com";
          smtp.host = "smtp.fastmail.com";
          userName = "adriano@zenitylabs.com";
          passwordCommand = "${pkgs.gopass}/bin/gopass show -o fastmail.com/zenity-aerc";
          mbsync = {
            enable = true;
            create = "both";
            expunge = "both";
            remove = "both";
          };
          msmtp.enable = true;
          notmuch.enable = true;
        };
      };
    };

    calendar.accounts = {
      fastmail.remote.passwordCommand = ["${pkgs.gopass}/bin/gopass" "show" "-o" "fastmail.com/me-aerc"];
    };
  };

  ai-agents = {
    enable = true;
    claude-code = {
      enable = true;
      marketplaces = {
        lsp-mux = {
          url = "https://git.sr.ht/~jcmuller/lsp-mux";
        };
        jcmuller-plugins = {
          url = "https://git.sr.ht/~jcmuller/claude-plugins";
        };
      };
      enabledPlugins = {
        "lsp-mux-nix-nix@lsp-mux" = true;
        "lsp-mux-go-nix@lsp-mux" = true;
        "lsp-mux-python@lsp-mux" = true;
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
    mcp = {
      context7 = {
        enable = true;
        patPath = config.age.secrets."opencode-context7-api-key".path;
      };
      github.patPath = config.age.secrets.opencode-github-mcp-pat.path;
      glean.enable = false;
      atlassian.enable = false;
    };
  };

  programs.qutebrowser.settings = {
    fonts.default_size = lib.mkForce "18px";
    zoom.default = "138%";
  };

  xdg = {
    enable = true;
    mime.enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = let
        browser = "org.qutebrowser.qutebrowser.desktop";
      in {
        "text/html" = browser;
        "x-scheme-handler/http" = browser;
        "x-scheme-handler/https" = browser;
        "x-scheme-handler/about" = browser;
        "x-scheme-handler/unknown" = browser;

        "x-scheme-handler/logseq" = "Logseq.desktop";
        "x-scheme-handler/slack" = "Slack.desktop";
      };
    };
  };
}
