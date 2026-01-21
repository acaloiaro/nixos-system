{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.ai-agents;
in {
  imports = [
    ./crush.nix
    ./opencode.nix
    ./mcp.nix
    ./lsp.nix
    ./skills.nix
  ];

  options.ai-agents = with lib;
  with types; {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable the AI Agents module.";
      example = lib.literalExpression ''
        {
          enable = true;
          crush.enable = true;
          opencode.enable = false;
          mcp = {
            glean.enable = false;
            atlassian.enable = false;
          };
        }
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    ai-agents.crush.enable = lib.mkDefault false;
    ai-agents.opencode.enable = lib.mkDefault true;

    home = {
      packages = with pkgs; [
        uv # for uvx
        nodejs
      ];
    };

    programs = {
      claude-code = {
        mcpServers = cfg.mcpServers;
        enable = true;
      };

      fabric-ai = {
        enable = false;
        enableZshIntegration = true;
      };
    };
  };
}
