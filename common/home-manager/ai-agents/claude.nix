{
  config,
  lib,
  ...
}: let
  cfg = config.ai-agents.claude-code;
in {
  options.ai-agents.claude-code = {
    enable =
      lib.mkEnableOption "Claude Code"
      // {
        default = true;
      };

    settings = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Settings passed through to programs.claude-code.settings.";
    };

    agents = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Custom agents passed through to programs.claude-code.agents.";
    };

    commands = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Custom commands passed through to programs.claude-code.commands.";
    };

    hooks = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Custom hooks passed through to programs.claude-code.hooks.";
    };

    memory = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Memory config passed through to programs.claude-code.memory.";
    };

    marketplaces = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          source = lib.mkOption {
            type = lib.types.enum ["git" "github" "url" "npm" "file" "directory"];
            default = "git";
            description = "Marketplace source type.";
          };
          url = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "URL for git or url source types.";
            example = "https://github.com/org/marketplace.git";
          };
          repo = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Repository in owner/repo format for github source type.";
            example = "my-org/claude-marketplace";
          };
          package = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Package name for npm source type.";
          };
          path = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Path for file, directory, github, or git source types.";
          };
        };
      });
      default = {};
      description = "Additional plugin marketplace sources, keyed by marketplace name.";
      example = {
        my-marketplace = {
          source = "github";
          repo = "my-org/claude-marketplace";
        };
      };
    };

    enabledPlugins = lib.mkOption {
      type = lib.types.attrsOf (lib.types.enum [true]);
      default = {};
      description = "Plugins to enable, in 'plugin@marketplace' format as keys with value true.";
      example = {
        "typescript-lsp@official" = true;
        "rust-lsp@official" = true;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.claude-code = {
      enable = true;
      settings = cfg.settings // lib.optionalAttrs (config.ai-agents.mcpServers != {}) {
        mcpServers = config.ai-agents.mcpServers;
      } // lib.optionalAttrs (cfg.marketplaces != {}) {
        extraKnownMarketplaces = lib.mapAttrs (_: mp: {
          source = lib.filterAttrs (_: v: v != null) {
            inherit (mp) source url repo package path;
          };
        }) cfg.marketplaces;
      } // lib.optionalAttrs (cfg.enabledPlugins != {}) {
        enabledPlugins = cfg.enabledPlugins;
      };
      agents = cfg.agents;
      commands = cfg.commands;
      hooks = cfg.hooks;
      memory = cfg.memory;
    };
  };
}
