{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.ai-agents;

  mkLspEnableOption = name:
    lib.mkOption {
      description = "Enable the ${name} LSP server";
      type = lib.types.bool;
      default = true;
      example = false;
    };

  # LSP configuration with proper extensionToLanguage mappings for Claude Code
  lspConfig =
    (lib.optionalAttrs cfg.lsp.go.enable {
      go = {
        command = lib.getExe pkgs.gopls;
        args = ["serve"];
        extensionToLanguage = {
          ".go" = "go";
        };
      };
    })
    // (lib.optionalAttrs cfg.lsp.nix.enable {
      nix = {
        command = lib.getExe pkgs.nil;
        extensionToLanguage = {
          ".nix" = "nix";
        };
      };
    })
    // (lib.optionalAttrs cfg.lsp.ruby.enable {
      ruby = {
        command = lib.getExe pkgs.solargraph;
        args = ["stdio"];
        env = {
          RUBYOPT = "-W0";
        };
        extensionToLanguage = {
          ".rb" = "ruby";
        };
      };
    })
    // (lib.optionalAttrs cfg.lsp.typescript.enable {
      typescript = {
        command = lib.getExe pkgs.typescript-language-server;
        args = ["--stdio"];
        extensionToLanguage = {
          ".ts" = "typescript";
          ".tsx" = "typescriptreact";
          ".js" = "javascript";
          ".jsx" = "javascriptreact";
        };
      };
    });
in {
  options.ai-agents.lsp = {
    go.enable = mkLspEnableOption "go";
    nix.enable = mkLspEnableOption "nix";
    ruby.enable = mkLspEnableOption "ruby";
    typescript.enable = mkLspEnableOption "typescript";
  };

  options.ai-agents.lspServers = lib.mkOption {
    description = "LSP Server Configurations (legacy, for MCP compatibility)";
    type = lib.types.attrs;
    default = {};
  };

  config = lib.mkIf cfg.enable {
    # Legacy format for MCP config (will be removed when MCP no longer uses LSP servers)
    ai-agents.lspServers = lib.mkMerge [
      (lib.mkIf cfg.lsp.go.enable {
        go.command = lib.getExe pkgs.gopls;
      })
      (lib.mkIf cfg.lsp.nix.enable {
        nix.command = lib.getExe pkgs.nil;
      })
      (lib.mkIf cfg.lsp.ruby.enable {
        ruby = {
          command = lib.getExe pkgs.solargraph;
          args = ["stdio"];
          env = {
            RUBYOPT = "-W0";
          };
        };
      })
      (lib.mkIf cfg.lsp.typescript.enable {
        typescript = {
          args = ["--stdio"];
          command = lib.getExe pkgs.typescript-language-server;
        };
      })
    ];

    # Generate .lsp.json for Claude Code
    xdg.configFile."claude-code/.lsp.json" = lib.mkIf (lspConfig != {}) {
      text = builtins.toJSON lspConfig;
    };
  };
}
