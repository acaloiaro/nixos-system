{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.ai-agents.claude-code.diff-review;
  hookScript = pkgs.writeTextFile {
    name = "diff-review.sh";
    executable = true;
    text = builtins.readFile ./diff-review.sh;
  };
in {
  options.ai-agents.claude-code.diff-review = {
    enable = lib.mkEnableOption "Claude Code diff-review hook";

    command = lib.mkOption {
      type = lib.types.str;
      default = "diff -u";
      description = "Diff command passed to the hook. Last two args are always original and proposed file paths. Store paths may be interpolated.";
      example = "run-in-zellij -- difft-review";
    };

    context = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to prepend Claude's reasoning as a comment to the original file in the diff.";
    };

    display = lib.mkOption {
      type = lib.types.enum ["auto"];
      default = "auto";
      description = "How to display the diff tool";
    };

    decision = lib.mkOption {
      type = lib.types.enum ["auto" "exit-code" "ask"];
      default = "exit-code";
      description = ''
        How the hook determines allow/deny after the diff tool exits.
        exit-code: non-zero exit rejects (works with vim-family, helix, and custom wrappers).
        ask: always prompt the user regardless of exit code.
        auto: exit-code for terminal tools, ask for GUI tools.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      (pkgs.writeShellApplication {
        name = "difft-review";
        runtimeInputs = with pkgs; [difftastic];
        text = ''
          difft "$1" "$2"
          printf "\nApprove? [y/N] "
          read -r r < /dev/tty
          [ "$r" = y ]
        '';
      })
    ];

    xdg.configFile."claude-diff-review/config.json".text = builtins.toJSON {
      enabled = true;
      command = cfg.command;
      context = cfg.context;
      decision = cfg.decision;
      display = "direct";
    };

    ai-agents.claude-code.settings.hooks = {
      PreToolUse = [
        {
          matcher = "Edit|Write";
          hooks = [
            {
              type = "command";
              command = "${hookScript}";
            }
          ];
        }
      ];
    };
  };
}
