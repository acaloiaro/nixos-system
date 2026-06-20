{
  config,
  pkgs,
  lib,
  kitty-grab,
  agenix,
  ...
}: let
  waybar-peek = pkgs.writeShellScriptBin "waybar-peek" ''
    case "$1" in
      show) pkill -SIGUSR1 waybar ;;
      hide) pkill -SIGUSR2 waybar ;;
    esac
  '';
in {
  imports = [
    ../../../common/accounts/calendars.nix
    ../../../common/applications/run-in-mux.nix
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
      swaylock
      ungoogled-chromium
      yazi
      zeal
      zsh
    ];
    sessionVariables = {
      "ELECTRON_OZONE_PLATFORM_HINT" = "auto";
      "GO111MODULE" = "on";
      "MOZ_ENABLE_WAYLAND" = "1";
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
    claude-code = {
      enable = true;
      settings = {
        hooks = {
          PreToolUse = [
            {
              matcher = "Edit|Write";
              hooks = [
                {
                  type = "command";
                  command = ''
                    hook_json=$(cat)
                    name=$(printf '%s' "$hook_json" | ${lib.getExe pkgs.jq} -r '
                      (.tool_name // "tool") as $t |
                      (.tool_input.file_path // "") as $f |
                      if $f == "" then "\($t): (no file)"
                      else "\($t): \($f | split("/") | last)"
                      end
                    ' 2>/dev/null || echo "claude-edit")
                    printf '%s' "$hook_json" | run-in-mux --name "$name" --width '100%' --x '0%' --y '5%' -- ${lib.getExe pkgs.hookable} --interactive --no-exit-code --accept-key 'ctrl+a' --reject-key 'ctrl+r' --cmd '${lib.getExe pkgs.adiff} -i'
                  '';
                }
              ];
            }
          ];
        };
        extraKnownMarketplaces = {
          jcmuller-plugins.source = {
            source = "git";
            url = "https://git.sr.ht/~jcmuller/claude-plugins";
          };
          lsp-mux.source = {
            source = "git";
            url = "https://git.sr.ht/~jcmuller/lsp-mux";
          };
          my-skills.source = {
            source = "github";
            repo = "acaloiaro/nixos-system";
          };
        };
        enabledPlugins = {
          "lsp-mux-go-nix@lsp-mux" = true;
          "lsp-mux-nix-nix@lsp-mux" = true;
          "lsp-mux-python@lsp-mux" = true;
          "adriano-voice@my-skills" = true;
          "adriano-voice-code-comments@my-skills" = true;
          "create-my-skills@my-skills" = true;
          "update-my-skills@my-skills" = true;
          "version-control@my-skills" = true;
        };
        includeCoAuthoredBy = false;
        mcpServers = config.ai-agents.mcpServers;
      };
      plugins = [
        (pkgs.fetchFromGitHub {
          owner = "mattpocock";
          repo = "skills";
          rev = "694fa30311e02c2639942308513555e61ee84a6f";
          hash = "sha256-NGRKdnHSBKoR48zGotmJ3zGXnQ58ogudv8T4Va/2DSY=";
        })
      ];
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    firefox = {
      configPath = ".mozilla/firefox";
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
    waybar = {
      enable = true;
      settings = [
        {
          layer = "overlay";
          position = "bottom";
          height = 24;
          start_hidden = true;
          "on-sigusr1" = "show";
          "on-sigusr2" = "hide";
          modules-left = ["sway/workspaces"];
          modules-center = [];
          modules-right = ["network" "memory" "cpu" "wireplumber" "battery" "tray"];
          "sway/workspaces" = {
            disable-scroll = true;
            all-outputs = true;
          };
          network = {
            interval = 5;
            format-wifi = "{essid} ({signalStrength}%)  ↓{bandwidthDownBytes} ↑{bandwidthUpBytes}";
            format-ethernet = "{ifname}  ↓{bandwidthDownBytes} ↑{bandwidthUpBytes}";
            format-disconnected = "disconnected";
          };
          memory = {
            interval = 5;
            format = " {used:.1f}G";
          };
          cpu = {
            interval = 5;
            format = " {usage}%";
          };
          wireplumber = {
            format = "{icon} {volume}%";
            format-muted = " muted";
            format-icons = ["" "" ""];
            on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          };
          battery = {
            interval = 30;
            format = "{icon} {capacity}%";
            format-charging = " {capacity}%";
            format-icons = ["" "" "" "" ""];
          };
          tray = {spacing = 10;};
        }
        {
          layer = "overlay";
          position = "top";
          height = 24;
          start_hidden = true;
          "on-sigusr1" = "show";
          "on-sigusr2" = "hide";
          modules-left = ["custom/whereami"];
          modules-center = [];
          modules-right = ["clock#pt" "clock#et" "clock#utc" "clock#cet" "clock#date"];
          "custom/whereami" = {
            exec = "curl -sf --max-time 10 https://jellybee.bison-lizard.ts.net/whereami 2>/dev/null | jq -r '\"\\(.conditions.emoji // \"\") \\(.conditions.label // \"\")  \\(.location.name // \"?\")  \\(.weather.tempf // \"?\")°F  \\(.weather.humidity // \"?\")%  💨 \\(.weather.windspeedmph // \"?\")mph\"' 2>/dev/null || echo '? whereami'";
            interval = 60;
            format = "{}";
          };
          "clock#pt" = {
            format = "PT {:%H:%M} ";
            timezone = "America/Los_Angeles";
            interval = 60;
          };
          "clock#et" = {
            format = "ET {:%H:%M} ";
            timezone = "America/New_York";
            interval = 60;
          };
          "clock#utc" = {
            format = "UTC {:%H:%M} ";
            timezone = "UTC";
            interval = 60;
          };
          "clock#cet" = {
            format = "CET {:%H:%M} ";
            timezone = "Europe/Berlin";
            interval = 60;
          };
          "clock#date" = {
            format = "{:%a %d/%m}";
            interval = 60;
          };
        }
      ];
      style = ''
        * {
          font-family: "Font Awesome 5 Free", "DejaVu Sans Mono";
          font-weight: bold;
          font-size: 16px;
          min-height: 0;
        }
        window#waybar {
          background: #2E3440;
          color: #81A1C1;
        }
        #network, #memory, #cpu, #wireplumber, #battery, #tray,
        #custom-whereami, #clock, #workspaces {
          padding: 0 8px;
          color: #81A1C1;
        }
        #workspaces button {
          padding: 0 4px;
          color: #4C566A;
        }
        #workspaces button.focused {
          color: #ECEFF4;
        }
        #battery.charging { color: #A3BE8C; }
        #battery.warning:not(.charging) { color: #EBCB8B; }
        #battery.critical:not(.charging) { color: #BF616A; }
      '';
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
        screenshot = ''grim -g "$(slurp)" ~/Pictures/$(date +%Y%m%d_%H%M%S).png'';
        screencopy = ''grim -g "$(slurp)" - | wl-copy'';
        screenrecord = ''wf-recorder -g "$(slurp)" -f ~/Videos/$(date +%Y%m%d_%H%M%S).mp4'';
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
    swayidle = {
      enable = true;
      timeouts = [
        {
          timeout = 30 * 60;
          command = "${pkgs.swaylock}/bin/swaylock -f -c 000000";
        }
      ];
      events = {
        before-sleep = "${pkgs.swaylock}/bin/swaylock -f -c 000000";
        lock = "${pkgs.swaylock}/bin/swaylock -f -c 000000";
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

  wayland.windowManager.sway = {
    enable = true;
    package = pkgs.symlinkJoin {
      name = "sway";
      paths = [
        (pkgs.writeShellScriptBin "sway" ''
          export XDG_CACHE_HOME=''${XDG_CACHE_HOME:-/tmp}
          exec ${pkgs.sway}/bin/sway "$@" 2>/tmp/sway.log
        '')
        pkgs.sway
      ];
    };
    config = rec {
      modifier = "Mod4";
      assigns = {
        "b:browser" = [{app_id = "^qutebrowser$";} {app_id = "chromium-browser";}];
        "t:term" = [{app_id = "^kitty$";}];
        "c:chat" = [{app_id = "beeper";} {app_id = "Beeper";} {class = "Beeper";} {app_id = "slack";} {class = "Slack";}];
        "n:notes" = [{app_id = "Logseq";} {app_id = "logseq";} {class = "Logseq";}];
      };
      bars = [];
      gaps = {
        inner = 3;
        outer = 1;
      };
      input = {
        "type:keyboard" = {
          xkb_layout = "us";
          xkb_options = "caps:ctrl_modifier";
          repeat_delay = "250";
          repeat_rate = "40";
        };
        "type:touchpad" = {
          accel_profile = "flat";
          pointer_accel = "0.5";
          natural_scroll = "enabled";
          dwt = "enabled";
          tap = "enabled";
        };
      };
      keybindings = lib.mkOptionDefault {
        # Workspaces
        "${modifier}+b" = "workspace b:browser; exec ${waybar-peek}/bin/waybar-peek hide";
        "${modifier}+c" = "workspace c:chat; exec ${waybar-peek}/bin/waybar-peek hide";
        "${modifier}+n" = "workspace n:notes; exec ${waybar-peek}/bin/waybar-peek hide";
        "${modifier}+t" = "workspace t:term; exec ${waybar-peek}/bin/waybar-peek hide";
        "${modifier}+u" = "workspace u:unassigned; exec ${waybar-peek}/bin/waybar-peek hide";
        "${modifier}+v" = "workspace v:video; exec ${waybar-peek}/bin/waybar-peek hide";
        "${modifier}+Shift+b" = "move container to workspace b:browser";
        "${modifier}+Shift+c" = "move container to workspace c:chat";
        "${modifier}+Shift+n" = "move container to workspace n:notes";
        "${modifier}+Shift+t" = "move container to workspace t:term";
        "${modifier}+Shift+u" = "move container to workspace u:unassigned";
        "${modifier}+Shift+v" = "move container to workspace v:video";
        # Remove default number bindings for renamed workspaces
        "${modifier}+1" = null;
        "${modifier}+2" = null;
        "${modifier}+3" = null;
        "${modifier}+4" = null;
        "${modifier}+5" = null;
        "${modifier}+Shift+1" = null;
        "${modifier}+Shift+2" = null;
        "${modifier}+Shift+3" = null;
        "${modifier}+Shift+4" = null;
        "${modifier}+Shift+5" = null;
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
        "XF86Display" = "exec ${pkgs.wlr-randr}/bin/wlr-randr --output DP-1 --on --mode 1920x1080 --pos 0,0";
        "XF86Go" = "exec playerctl play";
        "XF86MonBrightnessDown" = "exec brightnessctl set 4%-";
        "XF86MonBrightnessUp" = "exec brightnessctl set 4%+";
      };
      startup = [
        {command = "qutebrowser";}
        {command = "kitty";}
        {command = "beeper";}
        {command = "logseq";}
        {command = "waybar";}
      ];
      window = {
        border = 0;
        titlebar = false;
        commands = [
          {
            criteria = {instance = "chromium-browser";};
            command = "floating disable";
          }
          {
            criteria = {instance = "chromium-browser";};
            command = "focus";
          }
          {
            criteria = {app_id = ".blueman-manager-wrapped";};
            command = "focus";
          }
          {
            criteria = {app_id = ".blueman-manager-wrapped";};
            command = "floating disable";
          }
        ];
      };
      floating = {
        border = 0;
        titlebar = false;
      };
      workspaceAutoBackAndForth = true;
      workspaceLayout = "default";
      workspaceOutputAssign = [
        {
          output = "eDP-1";
          workspace = "b:browser";
        }
        {
          output = "eDP-1";
          workspace = "t:term";
        }
        {
          output = "eDP-1";
          workspace = "c:chat";
        }
        {
          output = "eDP-1";
          workspace = "n:notes";
        }
        {
          output = "eDP-1";
          workspace = "v:video";
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
    extraConfig = ''
      bindsym --no-repeat Super_L exec ${waybar-peek}/bin/waybar-peek show
      bindsym --release Super_L exec ${waybar-peek}/bin/waybar-peek hide
    '';
  };
}
