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
            type = "http";
            url = "https://api.githubcopilot.com/mcp";
            headers.Authorization = "{env:GITHUB_PERSONAL_ACCESS_TOKEN_MCP}";
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
            enabled = false;
            type = "remote";
            url = "https://mcp.context7.com/mcp";
            headers = {
              CONTEXT7_API_KEY = "{env:CONTEXT7_API_KEY}";
            };
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
        # greenhouse = {
        #   enabled = false;
        #   type = "remote";
        #   url = "http://localhost:3002/mcp/sse";
        #   headers = {
        #     authorization = "Bearer eyJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJsb2NhbGhvc3QtYXV0aC5ncmVlbmhvdXNlLmlvIiwic3ViIjo0MDAwMDAyMDAyLCJhdWQiOlsibG9jYWxob3N0LWhhcnZlc3QuZ3JlZW5ob3VzZS5pbyJdLCJleHAiOjE3NzE0NTMzMDUsImlhdCI6MTc3MTQ0OTcwNSwianRpIjoiTzlUaUFMZEFIV2g0NlFSdHUwelphQVJEMDc1M3hCQkMrR1ZqbmpTaDROdWhNdDNIeXkwbjVyUUZ6blN1bzVleiIsInNjb3BlIjoiaGFydmVzdDphcHBsaWNhdGlvbnM6bGlzdCBoYXJ2ZXN0OmNhbmRpZGF0ZXM6Y3JlYXRlIGhhcnZlc3Q6Y2FuZGlkYXRlczpsaXN0IGhhcnZlc3Q6Y2FuZGlkYXRlczp1cGRhdGUgaGFydmVzdDpqb2JzOmxpc3QgaGFydmVzdDp1c2VyczpsaXN0IiwidmVyc2lvbiI6MS4wLCJzaWxvIjoyLCJhbGxvd2VkX2lwcyI6W10sImFjdCI6eyJvcmdhbml6YXRpb24uaWQiOjQwMDAwMDAwMDIsIm9yZ2FuaXphdGlvbi5uYW1lIjoiQnVzaW5lc3MgY29ycG9yYXRpb24iLCJjcmVkZW50aWFsLnR5cGUiOiJBdXRoOjpQcm92aWRlcjo6TW9kZWxzOjpBY2Nlc3NUb2tlbk1ldGEiLCJjcmVkZW50aWFsLmlkIjo0MDAwMDI4MDAyLCJjcmVkZW50aWFsLmRlc2NyaXB0aW9uIjpudWxsLCJwYXJ0bmVyLmlkIjpudWxsLCJwYXJ0bmVyLm5hbWUiOm51bGwsImNsaWVudC5pZCI6IkNmR0JtMlhibE1tZ0UwdTRldG9PSzhNUEFiNlZCY1NTQjU5WDgwTTciLCJjbGllbnQubmFtZSI6IkdyZWVuaG91c2UgTUNQIFNlcnZlciIsImNsaWVudC50eXBlIjoiQXV0aDo6Q2xpZW50QXBwbGljYXRpb25zOjpNb2RlbHM6OkhhcnZlc3RNY3BDbGllbnRBcHBsaWNhdGlvbiJ9fQ.L60Kk29DWHSUDxrTO9DhZ_m-eR_RlDW0xqSdRl6RR4NpaZRz38iFzmA6X6LdKLezJG42r9z2j1wIWfE0nWkbUoKKoIBUClPsc7hzx8zbBXlHvnJlPHeI9RCmX82YV3WIlud7PvzHq73lw2tcrhIAu3XAI5AswMUKh9BaXBqaJk7_I7hQolSIqclR4tksXUacqVSOorOslvtVA_OJ0R1FvrqfauInYOgAxtw1IhtqqmU5Ykt61uCXAW_Hq0eznjMh0H9xfsUQhlLFtqtuvVzKjI8g05zLEt-gEoScBj__4lUv6AmQjd9fzTZRSBNoApjvuXzRiaRydVd29RZ_LU8KLSNeJqd1M5wN124n2s8BLp9jnp4fzJ0gw4cvjqOBoE2FX6B1uABlWacW7MWr7VQdqVXqnuLEUdE51K9g5QXkE8XFioVLT611nSGUiGPHhlB52_Si_oYSeDvYgSRQxN4mj-2eFcb2jefaPLDc5nMR7h-leLsPq2gJyYXxwxwIM8XlaJZWkqZF-Ua0WXn9IEtKhWX6hmNzKdVwfvSZ04Rgf2t8qdw3UxRw30-Tel7VCf_9GBgCV1GZjBPFJWf6613TQYdYgg_QhYgDzYjezuNJqjggRRF1xA-wcvajDqs_7dauKGgvJMzQTnPEn66H-Y83UIf3dx0VV7OniSVv14htj28";
        #   };
        # };
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
