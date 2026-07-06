{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.zellij;
  zj-which-key = pkgs.fetchurl {
    url = "https://github.com/johnae/zj-which-key/releases/download/v0.2.0/zj_which_key.wasm";
    sha256 = "1yy9kzy2c3xklsskmid7w3zr2f3041kx1a4r2f40bshjc8wdqbhy";
  };
in {
  options.modules.zellij = {
    enable = mkEnableOption "zellij terminal multiplexer";

    autoStart = mkOption {
      type = types.bool;
      default = true;
      description = "Automatically start zellij in zsh";
    };

    theme = mkOption {
      type = types.str;
      default = "nord";
      description = "Zellij color theme";
    };

    sessionSerialization = mkOption {
      type = types.bool;
      default = true;
      description = "Enable session serialization";
    };

    autoLayout = mkOption {
      type = types.bool;
      default = true;
      description = "Enable automatic layout management";
    };

    paneFrames = mkOption {
      type = types.bool;
      default = false;
      description = "Show frames around panes";
    };

    autoTabName = mkOption {
      type = types.bool;
      default = true;
      description = "Automatically rename tabs based on the focused pane's running process";
    };

    extraSettings = mkOption {
      type = types.attrs;
      default = {};
      description = "Additional settings to merge into the zellij configuration";
    };

    defaultSessionName = mkOption {
      type = types.str;
      default = "default";
      description = "Name of the session to create or attach to on shell startup";
    };

    defaultSessionLayout = mkOption {
      type = types.nullOr types.lines;
      default = null;
      description = "KDL layout content for the default session. When set, this is written to ~/.config/zellij/layouts/<defaultSessionName>.kdl and used on session creation.";
    };

    zjstatus = {
      enable = mkEnableOption "zjstatus status bar plugin";
    };

    zjWhichKey = {
      enable = mkEnableOption "zj-which-key plugin";
      autoShow = mkOption {
        type = types.bool;
        default = true;
        description = "Automatically show the which-key overlay";
      };
      delaySecs = mkOption {
        type = types.str;
        default = "0.3";
        description = "Delay in seconds before showing the overlay";
      };
      position = mkOption {
        type = types.str;
        default = "bottom-right";
        description = "Position of the which-key overlay";
      };
      maxHeightPct = mkOption {
        type = types.str;
        default = "40";
        description = "Maximum height as a percentage of the terminal";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [zellij];

    programs.zellij = {
      enable = true;
      settings =
        {
          theme = cfg.theme;
          session_serialization = cfg.sessionSerialization;
          auto_layout = cfg.autoLayout;
          auto_tab_name = cfg.autoTabName;
          pane_frames = cfg.paneFrames;
          default_layout = "compact";
          show_startup_tips = false;
          keybinds = {
            normal = {
              # Vim-style pane focus switching
              "bind \"Alt h\"" = {MoveFocusOrTab = "Left";};
              "bind \"Alt j\"" = {MoveFocus = "Down";};
              "bind \"Alt k\"" = {MoveFocus = "Up";};
              "bind \"Alt l\"" = {MoveFocusOrTab = "Right";};
              "bind \"Ctrl m\"" = {SwitchToMode = "Move";};
            };
            pane = {
              # Vim-style pane navigation in pane mode
              "bind \"h\"" = {MoveFocus = "Left";};
              "bind \"j\"" = {MoveFocus = "Down";};
              "bind \"k\"" = {MoveFocus = "Up";};
              "bind \"l\"" = {MoveFocus = "Right";};
            };
            tab = {
              # Vim-style tab navigation in tab mode
              "bind \"h\"" = {GoToPreviousTab = {};};
              "bind \"l\"" = {GoToNextTab = {};};
              "bind \"H\"" = {MoveTab = "Left";};
              "bind \"L\"" = {MoveTab = "Right";};
            };
          };
          themes = {
            custom-nord = {
              # Nord theme with custom light blue ribbon backgrounds
              text_unselected = {
                base = [229 233 240];
                background = [59 66 82];
                emphasis_0 = [208 135 112];
                emphasis_1 = [136 192 208];
                emphasis_2 = [163 190 140];
                emphasis_3 = [180 142 173];
              };
              text_selected = {
                base = [229 233 240];
                background = [59 66 82];
                emphasis_0 = [208 135 112];
                emphasis_1 = [136 192 208];
                emphasis_2 = [163 190 140];
                emphasis_3 = [180 142 173];
              };
              ribbon_selected = {
                base = [59 66 82];
                background = [94 129 172]; # Nord darker blue for active tab
                emphasis_0 = [191 97 106];
                emphasis_1 = [208 135 112];
                emphasis_2 = [180 142 173];
                emphasis_3 = [129 161 193];
              };
              ribbon_unselected = {
                base = [59 66 82];
                background = [136 192 208]; # Nord light blue (customized)
                emphasis_0 = [191 97 106];
                emphasis_1 = [229 233 240];
                emphasis_2 = [129 161 193];
                emphasis_3 = [180 142 173];
              };
              table_title = {
                base = [163 190 140];
                background = [0 0 0];
                emphasis_0 = [208 135 112];
                emphasis_1 = [136 192 208];
                emphasis_2 = [163 190 140];
                emphasis_3 = [180 142 173];
              };
              table_cell_selected = {
                base = [229 233 240];
                background = [46 52 64];
                emphasis_0 = [208 135 112];
                emphasis_1 = [136 192 208];
                emphasis_2 = [163 190 140];
                emphasis_3 = [180 142 173];
              };
              table_cell_unselected = {
                base = [229 233 240];
                background = [59 66 82];
                emphasis_0 = [208 135 112];
                emphasis_1 = [136 192 208];
                emphasis_2 = [163 190 140];
                emphasis_3 = [180 142 173];
              };
              list_selected = {
                base = [229 233 240];
                background = [46 52 64];
                emphasis_0 = [208 135 112];
                emphasis_1 = [136 192 208];
                emphasis_2 = [163 190 140];
                emphasis_3 = [180 142 173];
              };
              list_unselected = {
                base = [229 233 240];
                background = [59 66 82];
                emphasis_0 = [208 135 112];
                emphasis_1 = [136 192 208];
                emphasis_2 = [163 190 140];
                emphasis_3 = [180 142 173];
              };
              frame_selected = {
                base = [163 190 140];
                background = [0 0 0];
                emphasis_0 = [208 135 112];
                emphasis_1 = [136 192 208];
                emphasis_2 = [180 142 173];
                emphasis_3 = [0 0 0];
              };
              frame_highlight = {
                base = [208 135 112];
                background = [0 0 0];
                emphasis_0 = [180 142 173];
                emphasis_1 = [208 135 112];
                emphasis_2 = [208 135 112];
                emphasis_3 = [208 135 112];
              };
              exit_code_success = {
                base = [163 190 140];
                background = [0 0 0];
                emphasis_0 = [136 192 208];
                emphasis_1 = [59 66 82];
                emphasis_2 = [180 142 173];
                emphasis_3 = [129 161 193];
              };
              exit_code_error = {
                base = [191 97 106];
                background = [0 0 0];
                emphasis_0 = [235 203 139];
                emphasis_1 = [0 0 0];
                emphasis_2 = [0 0 0];
                emphasis_3 = [0 0 0];
              };
              multiplayer_user_colors = {
                player_1 = [180 142 173];
                player_2 = [129 161 193];
                player_3 = [0 0 0];
                player_4 = [235 203 139];
                player_5 = [136 192 208];
                player_6 = [0 0 0];
                player_7 = [191 97 106];
                player_8 = [0 0 0];
                player_9 = [0 0 0];
                player_10 = [0 0 0];
              };
            };
          };
        }
        // cfg.extraSettings;
      extraConfig = mkIf cfg.zjWhichKey.enable ''
        load_plugins {
            "file:${zj-which-key}" {
                auto_show "${if cfg.zjWhichKey.autoShow then "true" else "false"}"
                delay_secs "${cfg.zjWhichKey.delaySecs}"
                position "${cfg.zjWhichKey.position}"
                max_height_pct "${cfg.zjWhichKey.maxHeightPct}"
            }
        }
      '';
    };

    home.file = mkMerge [
      (mkIf (cfg.defaultSessionLayout != null) {
        ".config/zellij/layouts/${cfg.defaultSessionName}.kdl".text = cfg.defaultSessionLayout;
      })
      (mkIf (cfg.zjstatus.enable || cfg.zjWhichKey.enable) {
        ".cache/zellij/permissions.kdl".text =
          (optionalString cfg.zjstatus.enable ''
            "${pkgs.zellijPlugins.zjstatus}" {
                RunCommands
                ReadApplicationState
                ChangeApplicationState
            }
          '')
          + (optionalString cfg.zjWhichKey.enable ''
            "${zj-which-key}" {
                ReadApplicationState
                ChangeApplicationState
                MessageAndLaunchOtherPlugins
            }
          '');
      })
    ];

    programs.zsh = mkIf cfg.autoStart {
      initContent =
        if cfg.defaultSessionLayout != null
        then ''
          if [[ -z "$ZELLIJ" ]]; then
            if zellij list-sessions 2>/dev/null | grep -q "^${cfg.defaultSessionName}$"; then
              zellij attach ${cfg.defaultSessionName} -f
            else
              zellij -s ${cfg.defaultSessionName} -n ${cfg.defaultSessionName}
            fi
            if [[ "$ZELLIJ_AUTO_EXIT" == "true" ]]; then
              exit
            fi
          fi
        ''
        else ''
          eval "$(zellij setup --generate-auto-start zsh)"
        '';
    };
  };
}
