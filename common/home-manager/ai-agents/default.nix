{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.ai-agents;
  json = pkgs.formats.json {};
in {
  imports = [
    ./crush.nix
  ];

  options.ai-agents = with lib;
  with types; {
    enable = mkEnableOption "AI Agents";

    mcpServers = mkOption {
      description = "MCP Configurations";
      type = attrs;
      default = {
        git = {
          args = ["mcp-server-git" "--repository" "${config.home.homeDirectory}/proj/nixos-system"];
          command = "uvx";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    ai-agents.crush.enable = true;

    home = {
      file.".cursor/mcp.json".source = json.generate "cursor-mcp-config" {inherit (cfg) mcpServers;};

      packages = with pkgs; [
        nodejs_24 # for npx
        uv # for uvx
      ];
    };

    programs = {
      aider-chat.enable = true;
      codex.enable = true;

      opencode = {
        enable = true;
        enableMcpIntegration = true;
      };

      mcp = {
        enable = true;
        servers = cfg.mcpServers;
      };

      claude-code = {
        inherit (cfg) mcpServers;
        enable = true;
      };

      fabric-ai = {
        enable = true;
        enableZshIntegration = true;
      };
    };
  };
}
