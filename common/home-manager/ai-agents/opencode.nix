{
  config,
  lib,
  ...
}: let
  cfg = config.ai-agents.opencode;
in {
  options.ai-agents.opencode = {
    enable = lib.mkEnableOption "Opencode";
    extraConfig = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Extra configuration to merge into programs.opencode.";
      example = lib.literalExpression ''
        {
          rules = "Always use conventional commits.";
          settings.theme = "dracula";
        }
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs.opencode = lib.mkMerge [
      {
        enable = true;
        enableMcpIntegration = true;
        rules = "";
        settings = {
          theme = "nord";
          autoshare = false;
          autoupdate = true;
          plugin = [
            "@mohak34/opencode-notifier@latest"
          ];
          permission.bash = {
            "rm*" = "ask";
            "git *" = "ask";
            "jj git push*" = "ask";
          };
        };
      }
      cfg.extraConfig
    ];
  };
}
