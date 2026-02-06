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

    extraSettings = mkOption {
      type = types.attrs;
      default = {};
      description = "Additional settings to merge into the zellij configuration";
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
          pane_frames = cfg.paneFrames;
        }
        // cfg.extraSettings;
    };

    programs.zsh = mkIf cfg.autoStart {
      initExtra = ''
        eval "$(zellij setup --generate-auto-start zsh)"
      '';
    };
  };
}
