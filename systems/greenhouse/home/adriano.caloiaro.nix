{
  pkgs,
  lib,
  homeage,
  helix-flake,
  ...
}:
{
  imports = [
    homeage.homeManagerModules.homeage
    ../../../common/calendars.nix
    ../../../common/aerospace.nix
    ../../../common/greenhouse
  ];

  # homeage = {
  #   identityPaths = ["/home/adriano/.ssh/id_rsa_agenix"];
  #   installationType = "systemd";

  #   file."spotify-player-config" = {
  #     source = ../secrets/spotify_password.age;
  #     symlinks = ["${config.xdg.configHome}/spotifyd/password"];
  #   };
  # };
  modules.aerospace.enable = true;
  greenhouse = {
    enable = true;
    tooling = {
      enable = true;
      user = {
        name = "Adriano Caloiaro";
        email = "adriano.caloiaro@greenhouse.io";
        gpg-key-id = "FEC90D2844EA9541";
        ssh-public-key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINCARMVM8mwZBCFsnmr/hd0atFEj9oTOATzBajLGkS9V adriano.caloiaro@JJTH7GH17J";
      };
    };
    languages = {
      go.enable = true;
      terraform.enable = true;
      ruby.enable = true;
    };
  };
  programs.home-manager = {
    enable = true;
  };

  home = {
    stateVersion = "23.05";
    sessionVariables = {
      # FOO = "bar";
    };
    username = "adriano.caloiaro";
    homeDirectory = "/Users/adriano.caloiaro";
    activation.install-dictionaries = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        ${pkgs.qutebrowser}/share/qutebrowser/scripts/dictcli.py install en-US
      # '';
    packages = with pkgs; [
      choose-gui # Used as the selector for qute-pass (qutebrowser password management)
      dict
      glow
      nodePackages.prettier
      templ
      nil # nix lsp
      # vscode-html-language-server
      solargraph # ruby LSP
      yazi
      # zeal
    ];
    file = {
      ".qutebrowser/userscripts/qute-pass" = {
        text = ''
          #!/usr/bin/env bash
          PATH=$PATH:/run/current-system/sw/bin:/Users/adriano.caloiaro/.nix-profile/bin/ python3 ${pkgs.qutebrowser}/share/qutebrowser/userscripts/qute-pass $@
        '';
        executable = true;
      };
      #   ".mozilla/native-messaging-hosts/com.justwatch.gopass.json".source = ./gopass/gopass-api-manifest.json;
      #   ".config/gopass" = {
      #     source = ./gopass;
      #     recursive = true;
      #   };
      #   ".config/helix" = {
      #     source = ./helix;
      #     recursive = true;
      #   };
      #   ".config/nix" = {
      #     source = ./nix;
      #     recursive = true;
      #   };
      #   "${config.xdg.configHome}/kitty/kitty_grab" = {
      #     source = kitty-grab;
      #     recursive = true;
      #   };
      #   "${config.xdg.configHome}/kitty/grab.conf".source = ./kitty/kitty_grab.conf;
      #   "${config.xdg.configHome}/notmuch/querymap-personal".source = ./notmuch/querymap-personal;
      #   "${config.xdg.configHome}/notmuch/querymap-zenity".source = ./notmuch/querymap-zenity;
      #   "${config.xdg.configHome}/aerc/binds.conf".source = ./aerc/binds.conf;
      #   "${config.xdg.configHome}/mbsync/postExec" = {
      #     text = ''
      #       #!${pkgs.stdenv.shell}
      #       ${pkgs.notmuch}/bin/notmuch new
      #     '';
      #     executable = true;
      #   };
    };
  };

  # services.mbsync = {
  #   enable = true;
  #   postExec = "${config.xdg.configHome}/mbsync/postExec";
  # };

  # services.vdirsyncer.enable = true;

  programs.helix = {
    package = helix-flake.packages.${pkgs.system}.default;
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

  # programs.gh = {
  #   enable = true;

  #   gitCredentialHelper = {
  #     enable = true;
  #   };

  #   settings = {
  #     version = 1; # Workaround for https://github.com/nix-community/home-manager/issues/4744
  #     editor = "hx";
  #     git_protocol = "ssh";
  #   };
  # };

  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = "Adriano Caloiaro";
        email = "code@adriano.fyi";
      };
      signing = {
        backend = "ssh";
        key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINCARMVM8mwZBCFsnmr/hd0atFEj9oTOATzBajLGkS9V adriano.caloiaro@JJTH7GH17J";
      };
      git = {
        sign-on-push = true;
        write-change-id-header = true;
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
      font_size                14.0
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
      quickqr = "qrencode -t ansiutf8 $argv";
      jjd = ''jj diff '~ glob:"**/*_templ.txt" & ~ glob:"**/*_templ.go"' --git $argv'';
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
    # daemon = {
    #   enable = true;
    # };
    enableFishIntegration = true;
    settings = {
      enter_accept = false;
    };
    flags = [ "--disable-up-arrow" ];
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableScDaemon = true;

    maxCacheTtl = 60 * 60 * 24;
    defaultCacheTtl = 60 * 60 * 24;
    defaultCacheTtlSsh = 60 * 60 * 24;

    pinentry.package = pkgs.pinentry_mac;
  };

  # programs.firefox = {
  #   enable = true;
  #   package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
  #     extraPolicies = {
  #       CaptivePortal = false;
  #       DisableFirefoxStudies = true;
  #       DisablePocket = true;
  #       DisableTelemetry = true;
  #       DisableFirefoxAccounts = false;
  #       NoDefaultBookmarks = true;
  #       OfferToSaveLogins = false;
  #       OfferToSaveLoginsDefault = false;
  #       PasswordManagerEnabled = false;
  #       FirefoxHome = {
  #         Search = true;
  #         Pocket = false;
  #         Snippets = false;
  #         TopSites = false;
  #         Highlights = false;
  #       };
  #       UserMessaging = {
  #         ExtensionRecommendations = false;
  #         SkipOnboarding = true;
  #       };
  #     };
  #   };

  #   profiles = {
  #     adriano = {
  #       id = 0;
  #       name = "adriano";
  #       extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
  #         floccus
  #         ublock-origin
  #         gopass-bridge
  #         tridactyl
  #         noscript
  #       ];
  #     };
  #   };
  # };

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
    keyBindings =
      let
        pass_cmd = "spawn --userscript qute-pass --dmenu-invocation choose --mode gopass --password-store /Users/adriano.caloiaro/.local/share/gopass/stores/root";
      in
      {
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
      spellcheck.languages = [ "en-US" ];
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

      # zoom.default = "120%";
      content.javascript.clipboard = "access";
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
  # programs.mbsync.enable = true;
  # programs.msmtp.enable = true;
  # programs.notmuch = {
  #   enable = true;
  #   new.tags = ["new" "inbox"];
  #   hooks.postNew = ''
  #     ${pkgs.notmuch}/bin/notmuch tag +personal -- tag:new and folder:/Personal/
  #     ${pkgs.notmuch}/bin/notmuch tag +zenity -- tag:new and folder:/Zenity/
  #   '';
  # };

  # accounts = {
  #   email = {
  #     maildirBasePath = "/home/adriano/.mail";
  #     accounts = {
  #       Personal = {
  #         primary = true;
  #         aerc = {
  #           enable = true;
  #           # extraAccounts = {
  #           #   source = "notmuch:///home/adriano/.mail";
  #           #   maildir-store = "/home/adriano/.mail/Personal";
  #           #   query-map = "/home/adriano/.config/notmuch/querymap-personal";
  #           # };
  #         };
  #         realName = "Adriano Caloiaro";
  #         address = "me@adriano.fyi";
  #         imap.host = "imap.fastmail.com";
  #         smtp.host = "smtp.fastmail.com";
  #         userName = "me@adriano.fyi";
  #         passwordCommand = "${pkgs.gopass}/bin/gopass show -o fastmail.com/me-aerc";

  #         mbsync = {
  #           enable = true;
  #           create = "both";
  #           expunge = "both";
  #           remove = "both";
  #         };
  #         msmtp.enable = true;
  #         notmuch.enable = true;

  #         gpg = {
  #           encryptByDefault = true;
  #           signByDefault = true;
  #           key = "C2BC56DE73CE3F75!";
  #         };
  #       };

  #       Zenity = {
  #         primary = false;
  #         aerc = {
  #           enable = true;
  #           # extraAccounts = {
  #           #   source = "notmuch:///home/adriano/.mail";
  #           #   maildir-store = "/home/adriano/.mail/Zenity";
  #           #   query-map = "/home/adriano/.config/notmuch/querymap-zenity";
  #           # };
  #         };
  #         realName = "Adriano Caloiaro";
  #         address = "adriano@zenitylabs.com";
  #         imap.host = "imap.fastmail.com";
  #         smtp.host = "smtp.fastmail.com";
  #         userName = "adriano@zenitylabs.com";
  #         passwordCommand = "${pkgs.gopass}/bin/gopass show -o fastmail.com/zenity-aerc";
  #         mbsync = {
  #           enable = true;
  #           create = "both";
  #           expunge = "both";
  #           remove = "both";
  #         };
  #         msmtp.enable = true;
  #         notmuch.enable = true;
  #       };
  #     };
  #   };

  #   calendar.accounts = {
  #     fastmail.remote.passwordCommand = ["${pkgs.gopass}/bin/gopass" "show" "-o" "fastmail.com/me-aerc"];
  #   };
  # };
}
