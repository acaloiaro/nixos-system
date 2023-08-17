{ config, pkgs, lib, ... }:
{
  # This should be the same value as `system.stateVersion` in
  # your `configuration.nix` file.
  home.stateVersion = "23.05";
  xdg.enable = true;
  programs.home-manager.enable = true;

  home = {
    sessionVariables = {
      "GO111MODULE" = "on";
      "PGHOST" = "localhost";
      "PGUSER" = "postgres";
      "PGPASSWORD" = "postgres";
      "NOMAD_ADDR" = "http://cluster-0:4646";
    };

    file = {
      ".Xresources".source = ./Xresources;
      ".mozilla/native-messaging-hosts/com.justwatch.gopass.json".source = ./gopass/gopass-api-manifest.json;
      ".config/gopass" = {
         source = ./gopass;
         recursive = true;
      };
      ".config/tmux" = {
         source = ./tmux;
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
    };
  };

  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;

    config = rec {
      modifier = "Mod4";
      bars = [ 
        {
          position = "bottom";
          statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ~/.config/i3status-rust/config-bottom.toml";      
        }
      ];

      window.border = 0;

      gaps = {
        inner = 3;
        outer = 1;
      };

      keybindings = lib.mkOptionDefault {
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
      };

      startup = [
        {
          command = "exec i3-msg workspace 1";
          always = true;
          notification = false;
        }

        #{
        #  command = "${pkgs.feh}/bin/feh --bg-scale ~/background.png";
        #  always = true;
        #  notification = false;
        #}
      ];
    };
  }; 
    
  programs.i3status-rust = {
    enable = true;
    bars = {
      bottom = {
        blocks = [
          {
             block = "disk_space";
             path = "/";
             info_type = "available";
             interval = 60;
             warning = 20.0;
             alert = 10.0;
           }
           { 
             block = "battery";
           }
           {
             block = "memory";
           }
           {
             block = "cpu";
             interval = 1;
           }
           { 
             block = "sound"; 
           }
           {
             block = "time";
             interval = 60;
             format = " $timestamp.datetime(f:'%a %d/%m %R') ";
           }
        ];
        settings = {
          theme =  {
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
    settings = (builtins.fromTOML (builtins.readFile ./helix/config.toml));
    languages = { 
      langauge = (builtins.fromTOML (builtins.readFile ./helix/languages.toml)); 
    };
  };

  programs.git = {
    enable = true;
    userName  = "Adriano Caloiaro";
    userEmail = "code@adriano.fyi";

    signing = {
      key = "DCBD21758A309C1F41D7A0FC890FFDB11860FE1C";
      signByDefault = true;
    };
  };

  programs.kitty = {
    enable = true;
    theme = "GitHub Dark Dimmed"; # For normal/lower light environments 
    #theme = "GitHub Light"; # For higher light environments
    extraConfig = ''
#scrollback_pager nvim -c 'set clipboard=unnamedplus'  -c 'nnoremap <C-q> :quit!<CR>' -
background_opacity 0.76
draw_minimal_borders yes
window_padding_width 2
window_border_width 0
hide_window_decorations yes
titlebar-only yes
active_border_color none
    '';
  };

  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    shellAliases = {
      ll = "ls -l";
      vi = "hx $*";
      vim = "hx $*";
      rebuild = "sudo nixos-rebuild --flake .#z1 switch";
    };

    oh-my-zsh = {
      enable = true;
      theme = "eastwood";
      plugins = [
        "sudo"
        "git"
        "dotenv"
        "fzf"
      ];
    };

    initExtra = ''
    bindkey -v 
    export KEYTIMEOUT=1
    autoload edit-command-line 
    zle -N edit-command-line 

    # Change cursor shape for different vi modes.
    function zle-keymap-select {
      if [[ ''${KEYMAP} == vicmd ]] ||
         [[ $1 = 'block' ]]; then
        echo -ne '\e[1 q'

      elif [[ ''${KEYMAP} == main ]] ||
           [[ ''${KEYMAP} == viins ]] ||
           [[ ''${KEYMAP} = "" ]] ||
           [[ $1 = 'beam' ]]; then
        echo -ne '\e[5 q'
      fi
    }
    zle -N zle-keymap-select

    # Use beam shape cursor on startup.
    echo -ne '\e[5 q'

    # Use beam shape cursor for each new prompt.
    preexec() {
       echo -ne '\e[5 q'
    }

    
    alias addresses="vim ~/Nextcloud/Documents/Personal/Identification/addresses.md"
    alias ideas="vim ~/Nextcloud/Documents/Personal/ideas.md"
    alias notes="vim ~/Nextcloud/Documents/Notes"
    alias occ="ssh -t zenity-linode docker exec -u www-data nextcloud_app_1 ./occ $*"
    alias ohmyzsh="vim ~/.oh-my-zsh"
    alias open="xdg-open $*"
    alias people="vim ~/Nextcloud/Documents/Personal/people.md"
    alias shoppinglist="vi ~/Nextcloud/Documents/Personal/Shopping\ List.md"
    alias quickqr='a() { qrencode -o qr.png $1 && ((open qr.png; sleep 15; rm qr.png ) &)}; a &>/dev/null'
    alias xclip="xclip -selection clipboard $*"
    alias speedtest='echo "$(curl -skLO https://git.io/speedtest.sh && chmod +x speedtest.sh && ./speedtest.sh && rm speedtest.sh)"'
    alias colorlight="tmux set window-style 'fg=#171421,bg=#FFFDD0'"
    alias nix='nix --extra-experimental-features "nix-command flakes" $*'
    function gpgen { gopass generate "$1/$1@''${2=adriano.fyi}" }
  '';
  };

  services.screen-locker = {
    inactiveInterval = 1;
    lockCmd = "${pkgs.i3lock}/bin/i3lock -n -c 000000";
  };
  
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableZshIntegration = true;
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
            ublock-origin
            gopass-bridge
            tridactyl
            noscript 
          ];
      };
    };
  };

  programs.aerc = {
    enable = true;
    extraConfig = {
      general.unsafe-accounts-conf = true;
      ui = {
        this-day-time-format =''"           15:04"'';
        this-year-time-format = "Mon Jan 02 15:04";
        timestamp-format =      "2006-01-02 15:04";
        spinner = "[ ⡿ ],[ ⣟ ],[ ⣯ ],[ ⣷ ],[ ⣾ ],[ ⣽ ],[ ⣻ ],[ ⢿ ]";
      };
      triggers = {
        #new-email = ''exec notify-send "New email from %n" "%s"'';
      };
      filters = {
        "text/plain" = "colorize";
        "text/html" = "pandoc -f html -t plain";
        "text/calendar" = "calendar";
        "message/delivery-status" = "colorize";
        "message/rfc822" = "colorize";
        #"image/*" = "${pkgs.catimg}/bin/catimg -";
      };
    };
  };
  programs.mbsync.enable = true;
  programs.msmtp.enable = true;
  programs.notmuch = {
    enable = true;
    hooks = {
      #preNew = "mbsync --all";
    };
  };

  accounts.email.accounts = {
    Personal = {
      primary = true;
      aerc.enable = true;
      realName = "Adriano Caloiaro";
      address = "me@adriano.fyi";
      imap.host = "imap.fastmail.com";
      smtp.host = "smtp.fastmail.com";
      userName = "me@adriano.fyi";
      passwordCommand = "${pkgs.gopass}/bin/gopass show -o fastmail.com/me-aerc";

      mbsync = {
        enable = true;
        create = "maildir";
      };
      msmtp.enable = true;
      notmuch.enable = true;
    };

    
    Zenity = {
      primary = false;
      aerc.enable = true;
      realName = "Adriano Caloiaro";
      address = "adriano@zenitylabs.com";
      imap.host = "imap.fastmail.com";
      smtp.host = "smtp.fastmail.com";
      userName = "adriano@zenitylabs.com";
      passwordCommand = "${pkgs.gopass}/bin/gopass show -o fastmail.com/zenity-aerc";

      mbsync = {
        enable = true;
        create = "maildir";
      };
      msmtp.enable = true;
      notmuch.enable = true;
    };
  };

  services.mbsync = {
    enable = true;
    postExec = "${config.xdg.configHome}/mbsync/postExec";
  };

  xdg.configFile."mbsync/postExec" = {
    text = ''
    #!${pkgs.stdenv.shell}
    ${pkgs.notmuch}/bin/notmuch new
    '';
    executable = true;
  };
}

