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
    context7.enable = mkMcpEnableOption "context7";
    github.enable = mkMcpEnableOption "github";
    github.patPath = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Path to the decrypted file containing the GitHub Personal Access Token.";
    };
    context7.patPath = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Path to the decrypted file containing the Context7 API key";
    };
    circleci.enable = mkMcpEnableOption "circleci";
    circleci.patPath = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Path to the decrypted file containing the CircleCI API Token.";
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
      (lib.mkIf cfg.mcp.context7.enable (
        if cfg.mcp.context7.patPath != null
        then {
          context7 = {
            command = "${pkgs.bash}/bin/bash";
            args = [
              "-c"
              "exec ${pkgs.nodejs}/bin/npx -y @upstash/context7-mcp --api-key $(cat ${cfg.mcp.context7.patPath})"
            ];
          };
        }
        else {}
      ))
      (lib.mkIf cfg.mcp.circleci.enable (
        if cfg.mcp.circleci.patPath != null
        then {
          circleci = {
            command = "${pkgs.bash}/bin/bash";
            args = [
              "-c"
              "export CIRCLECI_TOKEN=$(cat ${cfg.mcp.circleci.patPath}) && exec ${pkgs.nodejs}/bin/npx -y @circleci/mcp-server-circleci@latest"
            ];
          };
        }
        else {}
      ))
      (lib.mkIf cfg.mcp.glean.enable {
        glean = {
          type = "http";
          url = "https://greenhouse-be.glean.com/mcp/default";
        };
        greenhouse = {
          type = "http";
          url = "http://localhost:3002/mcp";
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
