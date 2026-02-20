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
          url = "http://localhost:3002/mcp/sse";
          headers = {
            authorization = "Bearer eyJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJsb2NhbGhvc3QtYXV0aC5ncmVlbmhvdXNlLmlvIiwic3ViIjo0MDAwMDAxMDAyLCJhdWQiOlsibG9jYWxob3N0LWhhcnZlc3QuZ3JlZW5ob3VzZS5pbyJdLCJleHAiOjE3NzIxMzQyOTMsImlhdCI6MTc3MjA0Nzg5MywianRpIjoiYjNLcm50Q21rc096MDE0R1l4bkZrU3hkemVqN3NhTDBKS0F6cm05aEY3OTJHVmZZTzBYbGJGclNwRU9RM3RQaCIsInNjb3BlIjoiaGFydmVzdDphcHBsaWNhdGlvbnM6Y3JlYXRlIGhhcnZlc3Q6YXBwbGljYXRpb25zOmRlc3Ryb3kgaGFydmVzdDphcHBsaWNhdGlvbnM6bGlzdCBoYXJ2ZXN0OmFwcGxpY2F0aW9uczptb3ZlIGhhcnZlc3Q6YXBwbGljYXRpb25zOnJlamVjdCBoYXJ2ZXN0OmFwcGxpY2F0aW9uczp1bnJlamVjdCBoYXJ2ZXN0OmNhbmRpZGF0ZXM6Y3JlYXRlIGhhcnZlc3Q6Y2FuZGlkYXRlczpsaXN0IGhhcnZlc3Q6Y2FuZGlkYXRlczp1cGRhdGUgaGFydmVzdDpqb2JfaW50ZXJ2aWV3X3N0YWdlczpsaXN0IGhhcnZlc3Q6am9iczpjcmVhdGUgaGFydmVzdDpqb2JzOmxpc3QgaGFydmVzdDpub3RlczpjcmVhdGUgaGFydmVzdDpyZWplY3Rpb25fcmVhc29uczpsaXN0IGhhcnZlc3Q6c2NvcmVjYXJkczpsaXN0IGhhcnZlc3Q6dXNlcnM6bGlzdCIsInZlcnNpb24iOjEuMCwic2lsbyI6MiwiYWxsb3dlZF9pcHMiOltdLCJhY3QiOnsib3JnYW5pemF0aW9uLmlkIjo0MDAwMDAwMDAyLCJvcmdhbml6YXRpb24ubmFtZSI6IkJ1c2luZXNzIGNvcnBvcmF0aW9uIiwiY3JlZGVudGlhbC50eXBlIjoiQXV0aDo6UHJvdmlkZXI6Ok1vZGVsczo6QWNjZXNzVG9rZW5NZXRhIiwiY3JlZGVudGlhbC5pZCI6NDAwMDAxOTAwMiwiY3JlZGVudGlhbC5kZXNjcmlwdGlvbiI6bnVsbCwicGFydG5lci5pZCI6bnVsbCwicGFydG5lci5uYW1lIjpudWxsLCJjbGllbnQuaWQiOiJDZkdCbTJYYmxNbWdFMHU0ZXRvT0s4TVBBYjZWQmNTU0I1OVg4ME03IiwiY2xpZW50Lm5hbWUiOiJHcmVlbmhvdXNlIE1DUCBTZXJ2ZXIiLCJjbGllbnQudHlwZSI6IkF1dGg6OkNsaWVudEFwcGxpY2F0aW9uczo6TW9kZWxzOjpIYXJ2ZXN0TWNwQ2xpZW50QXBwbGljYXRpb24ifX0.fTmb623-6CjOppuyR7dZ6SC-HQx_ExqQMJoeNb0uT8ZjTCbCxyvLaDIr6gSd4Gonp96umGbj5Nja9PdfD0_mVuscP3_qUFpFgAioQRZ9m6LKZ8whFNVQN3_8CZnxiwc3OKqFqW9X_7AxGjkwhUU5bFsjtJYrY-sbt5GNwjuKSs-MTmMhtEwOZ6qCScE4s64sKUV-KUfhjAU72WFbPuDnVuX500HO9TNP6Yw1UHpPGFiWJTULcL-mZV3_SUZc6d8b0hN3Gaix9SWlMK0ueM3LrtnpNJ5vs1o8pvMw8rP2vISejN50HYPmraDDzk3Hp6H9VicrooDPVtJoH47PqSOb08AkMQL4IBi5694m2T3R-eyZU_UJog7t0C6C0PaQwYpw71OB3uTmsPPVatIlUQAnduN2KsTivqLKkjnLvNcFWlFmH1kiiv2pyX1eAZrqciFclBJw8UZyT-CQ9yuyNDrqZlHNrE4MSlF84eoQ9HUaLGQm1XKdckw__h4rxi89_x6yB1pqv3M6_KWs6XPllNT3svlNJlYH2RdLzmHvV9wwxqd6VRt2zJwictfgfKnVofRrM3-8e3DRkpGisq4RFmAI3g5_Tb7VrVFfRUtRL42c4D8q8As9ZOpvEQYahfgqKryhhH1P8RR29OExusUWPfmctz3WSajjsfp3660_eqR7h5g";
          };
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
