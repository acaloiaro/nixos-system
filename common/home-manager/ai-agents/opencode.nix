{
  config,
  lib,
  ...
}: let
  cfg = config.ai-agents.opencode;
in {
  options.ai-agents.opencode.enable = lib.mkEnableOption "Opencode";

  config = lib.mkIf cfg.enable {
    programs.opencode = {
      enable = true;
      enableMcpIntegration = true;
      rules = ''
      '';
      settings = {
        theme = "nord";
        autoshare = false;
        autoupdate = true;
      };
    };
  };
}
