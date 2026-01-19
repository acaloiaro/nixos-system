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
in {
  options.ai-agents.lsp = {
    go.enable = mkLspEnableOption "go";
    nix.enable = mkLspEnableOption "nix";
    ruby.enable = mkLspEnableOption "ruby";
    typescript.enable = mkLspEnableOption "typescript";
  };

  options.ai-agents.lspServers = lib.mkOption {
    description = "LSP Server Configurations";
    type = lib.types.attrs;
    default = {};
  };

  config = lib.mkIf cfg.enable {
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
  };
}
