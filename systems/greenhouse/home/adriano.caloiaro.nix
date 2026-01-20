{
  pkgs,
  config,
  lib,
  agenix,
  ...
}: {
  imports = [
    ../../../common/accounts/calendars.nix
    ../../../common/desktop/aerospace.nix
    ../../../common/secrets.nix
    ../../../common/home-manager/helix
    ../../../common/home-manager/jira
    ../../../common/home-manager/qutebrowser
    ../../../common/home-manager/ai-agents
    agenix.homeManagerModules.default
  ];

  age = {
    identityPaths = [
      "/Users/adriano.caloiaro/.ssh/id_ed25519_age"
    ];
    rekey = {
      hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE91Gv3hh4dkznl1o2+5xJQBEIvDVo7UWxjm93nQfRmE age-key-greenhouse";
      localStorageDir = ./. + "/secrets/rekeyed/";
    };
    secrets."circleci-mcp-pat" = {
      rekeyFile = ./secrets/circleci-mcp-pat.age;
    };
  };

  ai-agents = {
    enable = true;
    crush.enable = true;
    mcp.github.patPath = config.age.secrets."opencode-github-mcp-pat".path;
    mcp.circleci = {
      enable = true;
      patPath = config.age.secrets.circleci-mcp-pat.path;
    };
  };
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
      settings = {
        buffer = {
          images = true;
          cookies = true;
          cookie = "save";
        };
        external = {
          cookie-file = "~/.config/chawan/cookies.txt";
        };
      };
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    fish = {
      enable = true;
      shellAliases = {
        quickqr = "qrencode -t ansiutf8 $argv";
      };
      plugins = [
        {
          name = "plugin-git";
          src = pkgs.fishPlugins.plugin-git.src;
        }
      ];
      loginShellInit = ''
        # . $HOME/.nix-profile/share/asdf-vm/asdf.fish
      '';
    };
    fzf = {
      enable = true;
      enableFishIntegration = true;
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
      environment = {
        # for gemini
        "GOOGLE_CLOUD_PROJECT" = "elegant-pipe-468016-d8";
        "GOOGLE_CLOUD_LOCATION" = "global";
        # for gemini via crush
        "VERTEXAI_LOCATION" = "$GOOGLE_CLOUD_LOCATION";
        "VERTEXAI_PROJECT" = "$GOOGLE_CLOUD_PROJECT";
      };

      shellIntegration.enableFishIntegration = true;
    };
    starship = {
      enable = true;
      enableFishIntegration = true;
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
      agenix
      alejandra
      choose-gui # Used as the selector for qute-pass (qutebrowser password management)
      clang
      darwin.libffi
      dict
      gemini-cli
      glow
      go-grip # local markdown rendering in the browser
      jiratui
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
      ".config/jiratui/config.toml" = {
        text = ''
          jira_api_username: 'adriano.caloiaro@greenhouse.io'
          jira_api_token: '12345'
          jira_api_base_url: 'https://greenhouseio.atlassian.net'
        '';
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
