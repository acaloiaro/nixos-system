{
  config,
  pkgs,
  lib,
  kitty-grab,
  homeage,
  ...
}: {
  imports = [
    homeage.homeManagerModules.homeage
    ../../../common/calendars.nix
    ../../../common/chawan.nix
  ];

  homeage = {
    identityPaths = ["/home/adriano/.ssh/id_rsa_agenix"];
    installationType = "systemd";

    file."spotify-player-config" = {
      source = ../secrets/spotify_password.age;
      symlinks = ["${config.xdg.configHome}/spotifyd/password"];
    };
  };

  programs.home-manager = {
    enable = true;
  };
  home = {
    stateVersion = "23.05";
    sessionVariables = {
      "GO111MODULE" = "on";
      "NOMAD_ADDR" = "http://cluster-0:4646";
      "PATH" = "$PATH:/home/adriano/go/bin";
    };
    activation.install-dictionaries = lib.hm.dag.entryAfter ["writeBoundary"] ''
      ${pkgs.qutebrowser}/share/qutebrowser/scripts/dictcli.py install en-US
      ${pkgs.qutebrowser}/share/qutebrowser/scripts/dictcli.py install es-ES
    '';

    file = {
      ".mozilla/native-messaging-hosts/com.justwatch.gopass.json".source = ./gopass/gopass-api-manifest.json;
      ".config/gopass" = {
        source = ./gopass;
        recursive = true;
      };
      ".config/helix" = {
        source = ./helix;
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
    package = pkgs.i3-gaps;

    config = rec {
      modifier = "Mod4";
      bars = [
        {
          trayOutput = "primary";
          position = "bottom";
          statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ~/.config/i3status-rust/config-bottom.toml";
          fonts = {
            names = ["DejaVu Sans Mono" "FontAwesome5Free"];
            style = "Bold Semi-Condensed";
            size = 14.0;
          };
        }
      ];

      workspaceAutoBackAndForth = true;
      window.border = 0;

      workspaceOutputAssign = [
        {
          workspace = "1:Web";
          output = "eDP-1";
        }
        {
          workspace = "2:Termainl";
          output = "eDP-1";
        }
        {
          workspace = "3:Chat";
          output = "eDP-1";
        }
        {
          workspace = "4:Notes";
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
        "XF86AudioMute" = "exec amixer set Master toggle";
        "XF86AudioLowerVolume" = "exec amixer set Master 4%-";
        "XF86AudioRaiseVolume" = "exec amixer set Master 4%+";
        "XF86MonBrightnessDown" = "exec brightnessctl set 4%-";
        "XF86MonBrightnessUp" = "exec brightnessctl set 4%+";
        "${modifier}+Return" = "exec ${pkgs.kitty}/bin/kitty";
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
        "1: Web" = [{class = "^qutebrowser$";}];
        "2: Term" = [{class = "^kitty$";}];
        "3: Chat" = [{class = "^Beeper$";}];
        "4: Notes" = [{class = "^Logseq$";}];
        "5: 1PW" = [{class = "^1Password$";}];
        "6: Altchat" = [{class = "^Slack$";}];
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
      bottom = {
        blocks = [
          {
            block = "custom";
            command = "sed 's/  //' <(curl 'https://wttr.in/St.%20George,UT?format=4&u' -s)";
            interval = 1200;
          }
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
          {
            block = "time";
            interval = 60;
            format = " $timestamp.datetime(f:'%a %d/%m %R') ";
          }
        ];
        settings = {
          theme = {
            theme = "solarized-dark";
          };
        };
        icons = "awesome5";
        theme = "gruvbox-dark";
      };
    };
  };

  programs.helix = {
    enable = true;
    defaultEditor = true;
    settings = builtins.fromTOML (builtins.readFile ./helix/config.toml);
    languages = {
      langauge = builtins.fromTOML (builtins.readFile ./helix/languages.toml);
    };
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = builtins.fromTOML (builtins.readFile ./starship/config.toml);
  };

  programs.git = {
    enable = true;
    userName = "Adriano Caloiaro";
    userEmail = "code@adriano.fyi";

    signing = {
      key = "C2BC56DE73CE3F75!";
      signByDefault = true;
    };

    aliases = {
      d = "difftool -y --extcmd=icdiff";
    };

    extraConfig = {
      push = {
        autoSetupRemote = true;
      };
      init = {
        defaultBranch = "main";
      };
      pull = {
        rebase = true;
      };
    };
  };

  programs.gh = {
    enable = true;

    gitCredentialHelper = {
      enable = true;
    };

    settings = {
      version = 1; # Workaround for https://github.com/nix-community/home-manager/issues/4744
      editor = "hx";
      git_protocol = "ssh";
    };
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = "Adriano Caloiaro";
        email = "code@adriano.fyi";
      };
      signing = {
        backend = "gpg";
        key = "C2BC56DE73CE3F75!";
      };
      git = {
        sign-on-push = true;
      };
      ui = {
        paginate = "never";
        default-command = "log";
      };
    };
  };

  programs.kitty = {
    enable = true;
    themeFile = "GitHub_Dark_Dimmed"; # For normal/lower light environments
    # theme = "GitHub Light"; # For higher light environments
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
      font_size                12.0
    '';
    shellIntegration.enableFishIntegration = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  programs.fish = {
    enable = true;
    shellAliases = {
      addresses = "hx ~/KB/pages/Important\ Addresses.md";
      ideas = "hx ~/KB/pages/Notes/ideas/";
      people = "vim ~/KB/pages/People.md";
      notes = "hx ~/KB";
      open = "xdg-open $argv";
      quickqr = "qrencode -t ansiutf8 $1";
      gpgen = "gopass generate '$1/$1@adriano.fyi'";
      ll = "ls -l";
      vi = "hx $argv";
      vim = "hx $argv";
      rebuild = "sudo nixos-rebuild --flake .#zw switch";
      rebuild-roampi = "nixos-rebuild switch --flake .#roampi --target-host pi@roampi --build-host pi@roampi --fast --use-remote-sudo";
      nomad = "NOMAD_TOKEN=$(${pkgs.gopass}/bin/gopass show hetzner-cluster| grep admin_token | awk '{print $2}') nomad $argv;";
      chatgpt = "OPENAI_API_KEY=$(${pkgs.gopass}/bin/gopass show openai.com/openai.com@adriano.fyi | grep api | cut -d ' ' -f 2) ${pkgs.chatgpt-cli}/bin/chatgpt $argv";
      gbr = "git checkout $(git for-each-ref --sort='-authordate:iso8601' --format=' %(authordate:relative)%09%(refname:short)' refs/heads | fzf | awk '{print $4}')";
    };
    plugins = [
      {
        name = "plugin-git";
        src = pkgs.fishPlugins.plugin-git.src;
      }
    ];
  };
  programs.atuin = {
    enable = true;
    daemon = {
      enable = true;
    };
    enableFishIntegration = true;
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
        extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          floccus
          ublock-origin
          gopass-bridge
          tridactyl
          noscript
        ];
      };
    };
  };

  programs.qutebrowser = {
    enable = true;
    searchEngines = {
      DEFAULT = "https://kagi.com/search?q={}";
      ddg = "https://duckduckgo.com/?q={}";
      hm = "https://mipmip.github.io/home-manager-option-search/?query={}";
      nixpkgs = "https://search.nixos.org/packages?query={}";
      nixos = "https://search.nixos.org/options?query={}";
      nixman = "https://nixos.org/manual/nix/unstable/?search={}";
    };
    keyBindings = let
      pass_cmd = "spawn --userscript qute-pass --dmenu-invocation dmenu --mode gopass --password-store ~/.password-store";
    in {
      normal = {
        ",p" = pass_cmd;
        ",Pu" = "${pass_cmd} --username-only";
        ",Pp" = "${pass_cmd} --password-only";
        ",Po" = "${pass_cmd} --otp-only";
        ",," = "config-cycle tabs.show never always";
        ",qc" = "spawn --userscript ~/.local/bin/qute-logseq";
      };
    };
    quickmarks = {
      nixpkgs = "https://github.com/NixOS/nixpkgs";
      home-manager = "https://github.com/nix-community/home-manager";
    };
    settings = {
      spellcheck.languages = ["en-US"];
      tabs = {
        position = "top";
        show = "always";
        title = {
          format = "{audio}{current_title}";
          format_pinned = "{audio}📌 {current_title}";
        };
      };
      fonts = {
        default_size = "16px";
      };

      zoom.default = "120%";
      content.javascript.clipboard = "access";
    };
  };

  programs.chawan = {
    enable = true;
    images = true;
    cookie = true;
    cookie-jars-for = ["kagi.com" "sr.ht"];
    pager-keybindings = {"C-k" = ''() => pager.load("kagi:")'';};
    omnirules = [
      {
        match = "^kagi:";
        substitute-url =
          # js
          ''(x) => "https://kagi.com/search/?q=" + encodeURIComponent(x.split(":").slice(1).join(":"))'';
      }
    ];
    siteconf = [
      {
        url = "https://news.ycombinator.com/.*";
        cookie = true;
      }
    ];
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
        PastSight = {
          primary = true;
          aerc = {
            enable = true;
          };
          realName = "Adriano Caloiaro";
          address = "adriano@pastsight.com";
          imap.host = "imap.gmail.com";
          smtp.host = "smtp.gmail.com";
          userName = "adriano@pastsight.com";
          passwordCommand = "${pkgs.gopass}/bin/gopass show -o google.com/aerc/adriano@pastsight.com";

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

        Personal = {
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
      "PastSight" = {
        vdirsyncer = {
          clientIdCommand = ["${pkgs.gopass}/bin/gopass" "show" "-o" "google.com/adriano@pastsight.com/zw-dav-access-client-id"];
          clientSecretCommand = ["${pkgs.gopass}/bin/gopass" "show" "-o" "google.com/adriano@pastsight.com/zw-dav-access-client-secret"];
        };
      };
    };
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
    desktopEntries = {
      beeper-desktop = {
        name = "Beeper";
        type = "Application";
        exec = "beeper %U";
        icon = "beeper";
      };
    };
  };
}
