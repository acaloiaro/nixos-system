{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.ai-agents.crush;
in {
  options.ai-agents.crush.enable = lib.mkEnableOption "Charmbracelet's Crush";

  config = lib.mkIf cfg.enable {
    home.packages = [
      (pkgs.buildGo125Module rec {
        name = "crush";
        version = "0.32.0";
        vendorHash = "sha256-HauqqSrdpJFKV60BA2/2ZFaMz/wFwRf0+Te4zX34NsU=";

        src = pkgs.fetchFromGitHub {
          owner = "charmbracelet";
          repo = name;
          tag = "v${version}";
          hash = "sha256-EXHyYpIUGew2AwRqN7CU/A3YXF3HLGkkCgK2jYhSNnA=";
        };

        checkFlags = let
          # these tests fail in the sandbox
          skippedTests = [
            "TestCoderAgent"
            "TestOpenAIClientStreamChoices"
            "TestGrepWithIgnoreFiles"
            "TestSearchImplementations"
          ];
        in ["-skip=^${builtins.concatStringsSep "$|^" skippedTests}$"];
      })
    ];

    programs = {
      git.ignores = [".crush"];
      fish.loginShellInit =
        #fish
        ''
          eval "$(crush completion fish)"
        '';
    };

    xdg.configFile."crush/crush.json".source = (pkgs.formats.json {}).generate "crush-config" {
      "$schema" = "https://charm.land/crush.json";

      lsp = config.ai-agents.lspServers;

      mcp = let
        transformMcpServer = name: server: {
          name = name;
          value =
            {
              disabled = false;
              timeout = 120;
            }
            // (
              server
              // (
                if server ? url
                then
                  if ((builtins.match ".*sse.*" server.url) == null)
                  then {type = "http";}
                  else {type = "sse";}
                else if server ? command
                then {type = "stdio";}
                else {}
              )
            );
        };
      in
        lib.listToAttrs (lib.mapAttrsToList transformMcpServer config.ai-agents.mcpServers);
    };
  };
}
