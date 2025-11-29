{
  pkgs,
  config,
  lib,
  homeage,
  helix-flake,
  ...
}: {
  imports = [
    homeage.homeManagerModules.homeage
    ../../../common/calendars.nix
    ../../../common/aerospace.nix
  ];

  modules.aerospace.enable = true;
  programs = {
    aerc = {
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
    atuin = {
      enable = true;
      # daemon = {
      #   enable = true;
      # };
      enableFishIntegration = true;
      settings = {
        enter_accept = false;
      };
      flags = ["--disable-up-arrow"];
    };
    chawan = {
      enable = true;
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    fish = {
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
      loginShellInit = ''
        . $HOME/.nix-profile/share/asdf-vm/asdf.fish
      '';
    };
    fzf = {
      enable = true;
      enableFishIntegration = true;
    };
    helix = {
      package = helix-flake.packages.${pkgs.system}.default;
      enable = true;
      defaultEditor = true;
      settings = builtins.fromTOML (builtins.readFile ./helix/config.toml);
      languages = builtins.fromTOML (builtins.readFile ./helix/languages.toml);
    };
    home-manager.enable = true;
    kitty = {
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
    starship = {
      enable = true;
      enableFishIntegration = true;
      settings = builtins.fromTOML (builtins.readFile ./starship/config.toml);
    };
    qutebrowser = {
      enable = true;
      searchEngines = {
        DEFAULT = "https://kagi.com/search?q={}";
        ddg = "https://duckduckgo.com/?q={}";
        hm = "https://home-manager-options.extranix.com/?query={}";
        nixpkgs = "https://search.nixos.org/packages?query={}";
        nixos = "https://search.nixos.org/options?query={}";
        nixman = "https://nixos.org/manual/nix/unstable/?search={}";
      };
      keyBindings = let
        pass_cmd = "spawn --userscript qute-pass --dmenu-invocation choose --mode gopass --password-store /Users/adriano.caloiaro/.local/share/gopass/stores/root";
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
        url.start_pages = [
          "https://kagi.com"
        ];
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

        # zoom.default = "120%";
        content.javascript.clipboard = "access";
      };
    };
  };

  home = {
    stateVersion = "23.05";
    sessionVariables = {
      # FOO = "bar";
    };
    username = "adriano.caloiaro";
    homeDirectory = "/Users/adriano.caloiaro";
    activation.install-dictionaries = lib.hm.dag.entryAfter ["writeBoundary"] ''
        ${pkgs.qutebrowser}/share/qutebrowser/scripts/dictcli.py install en-US
      # '';
    packages = with pkgs; [
      alejandra
      choose-gui # Used as the selector for qute-pass (qutebrowser password management)
      clang
      darwin.libffi
      dict
      gemini-cli
      glow
      llvm
      nodePackages.prettier
      patchy
      templ
      nil # nix lsp
      yazi
      # zeal
    ];
    file = {
      ".config/home-manager".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/proj/nixos-system";
      ".qutebrowser/userscripts/qute-pass" = {
        text = ''
          #!/usr/bin/env bash
          PATH=$PATH:/run/current-system/sw/bin:/Users/adriano.caloiaro/.nix-profile/bin/ python3 ${pkgs.qutebrowser}/share/qutebrowser/userscripts/qute-pass $@
        '';
        executable = true;
      };
    };
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
}
