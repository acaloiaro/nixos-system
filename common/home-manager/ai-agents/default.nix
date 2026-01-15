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
        glean = {
          type = "http";
          url = "https://greenhouse-be.glean.com/mcp/default";
        };
        jira = {
          type = "http";
          url = "https://mcp.atlassian.com/v1/mcp";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    ai-agents.crush.enable = true;

    home = {
      packages = with pkgs; [
        uv # for uvx
      ];
    };

    programs = {
      # aider-chat.enable = true;
      # codex.enable = true;

      opencode = {
        enable = true;
        enableMcpIntegration = true;
        rules = ''
        '';
        settings = {
          theme = "opencode";
          # model = "anthropic/claude-sonnet-4-20250514";
          autoshare = false;
          autoupdate = true;
        };
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
        enable = false;
        enableZshIntegration = true;
      };
    };
  };
}
