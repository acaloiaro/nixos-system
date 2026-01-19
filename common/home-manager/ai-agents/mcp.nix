{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.ai-agents;

  mkMcpEnableOption = name:
    lib.mkOption {
      description = "Enable the ${name} MCP server";
      type = lib.types.bool;
      default = true;
      example = false;
    };
in {
  options.ai-agents.mcp = {
    git.enable = mkMcpEnableOption "git";
    github.enable = mkMcpEnableOption "github";
    github.patPath = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to the decrypted file containing the GitHub Personal Access Token.";
    };
    glean.enable = mkMcpEnableOption "glean";
    atlassian.enable = mkMcpEnableOption "atlassian";
  };

  options.ai-agents.mcpServers = lib.mkOption {
    description = "MCP Configurations";
    type = lib.types.attrs;
    default = {};
  };

  config = lib.mkIf cfg.enable {
    ai-agents.mcpServers = lib.mkMerge [
      (lib.mkIf cfg.mcp.git.enable {
        git = {
          args = ["mcp-server-git" "--repository" "${config.home.homeDirectory}/proj/nixos-system"];
          command = "uvx";
        };
      })
      (lib.mkIf cfg.mcp.github.enable (
        if cfg.mcp.github.patPath != null
        then {
          github = {
            command = "${pkgs.bash}/bin/bash";
            args = [
              "-c"
              "export GITHUB_PERSONAL_ACCESS_TOKEN=$(cat ${cfg.mcp.github.patPath}) && exec ${pkgs.nodejs}/bin/npx -y @modelcontextprotocol/server-github"
            ];
          };
        }
        else {
          github = {
            # Opencode is not yet compatible with using github's remote MCP server with oauth
            type = "http";
            url = "https://api.githubcopilot.com/mcp/";
          };
        }
      ))
      (lib.mkIf cfg.mcp.glean.enable {
        glean = {
          type = "http";
          url = "https://greenhouse-be.glean.com/mcp/default";
        };
      })
      (lib.mkIf cfg.mcp.atlassian.enable {
        atlassian = {
          type = "http";
          url = "https://mcp.atlassian.com/v1/mcp";
        };
      })
    ];

    programs.mcp = {
      enable = true;
      servers = cfg.mcpServers;
    };
  };
}
