{
  config,
  lib,
  ...
}: let
  cfg = config.ai-agents.claude-code;
  parentCfg = config.ai-agents;
in {
  options.ai-agents.claude-code = {
    enable = lib.mkEnableOption "Claude Code";
    extraConfig = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Extra configuration to merge into programs.claude-code.";
      example = lib.literalExpression ''
        {
          settings = {
            theme = "dark";
          };
        }
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs.claude-code = lib.mkMerge [
      {
        enable = true;
        mcpServers = parentCfg.mcpServers;
        settings.model = "claude-sonnet-4-5";
      }
      cfg.extraConfig
    ];
  };
}
