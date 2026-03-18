{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.zellij;
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
    };

    home.file = mkIf (cfg.defaultSessionLayout != null) {
      ".config/zellij/layouts/${cfg.defaultSessionName}.kdl".text = cfg.defaultSessionLayout;
    };

    programs.zsh = mkIf cfg.autoStart {
      initContent =
        if cfg.defaultSessionLayout != null
        then ''
          if [[ -z "$ZELLIJ" ]]; then
            if zellij list-sessions 2>/dev/null | grep -q "^${cfg.defaultSessionName}$"; then
              zellij attach ${cfg.defaultSessionName}
            else
              zellij -s ${cfg.defaultSessionName} -l ${cfg.defaultSessionName}
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
