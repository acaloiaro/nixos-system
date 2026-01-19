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

    githubPatPath = mkOption {
      type = nullOr path;
      default = null;
      description = "Path to the decrypted file containing the GitHub Personal Access Token.";
    };

    mcpServers = mkOption {
      description = "MCP Configurations";
      type = attrs;
      default = {
        git = {
          args = ["mcp-server-git" "--repository" "${config.home.homeDirectory}/proj/nixos-system"];
          command = "uvx";
        };
        github =
          if cfg.githubPatPath != null
          then {
            command = "${pkgs.bash}/bin/bash";
            args = [
              "-c"
              "export GITHUB_PERSONAL_ACCESS_TOKEN=$(cat ${cfg.githubPatPath}) && exec ${pkgs.nodejs}/bin/npx -y @modelcontextprotocol/server-github"
            ];
          }
          else {
            # Opencode is not yet compatible with using github's remote MCP server with oauth
            type = "http";
            url = "https://api.githubcopilot.com/mcp/";
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
    ai-agents.crush.enable = false;

    home = {
      packages = with pkgs; [
        uv # for uvx
        nodejs
      ];
    };

    programs = {
      opencode = {
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
