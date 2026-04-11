{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.ai-agents;
in {
  imports = [
    ./opencode.nix
    ./claude.nix
    ./diff-review.nix
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
    ai-agents.opencode.enable = lib.mkDefault true;

    home = {
      packages = with pkgs; [
        uv # for uvx
        nodejs
      ];
    };

    programs.zsh.initContent = ''
      # bash
      ${lib.optionalString (cfg.mcp.github.patPath != null) ''
        if [ -f "${cfg.mcp.github.patPath}" ]; then
          export GITHUB_PERSONAL_ACCESS_TOKEN=$(cat "${cfg.mcp.github.patPath}")
        fi
      ''}
      ${lib.optionalString (cfg.mcp.context7.patPath != null) ''
        if [ -f "${cfg.mcp.context7.patPath}" ]; then
          export CONTEXT7_API_KEY=$(cat "${cfg.mcp.context7.patPath}")
        fi
      ''}
    '';
  };
}
