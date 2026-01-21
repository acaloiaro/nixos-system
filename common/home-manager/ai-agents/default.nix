{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.ai-agents;

  compile-ai-skills = pkgs.writeShellApplication {
    name = "compile-ai-skills";
    runtimeInputs = with pkgs; [coreutils findutils];
    text = ''
      set -euo pipefail
      mkdir -p "${cfg.skills-dir}"
      find "${config.xdg.configHome}/skills/sources" -name SKILL.md -print0 |
        xargs -0 dirname |
        xargs -r ln -s -t "${cfg.skills-dir}" -f
    '';
  };

  sync-anthropic-skills = pkgs.writeShellApplication {
    name = "sync-anthropic-skills";
    runtimeInputs = with pkgs; [git coreutils];
    text = ''
      set -euo pipefail
      REPO_URL="https://github.com/anthropics/skills.git"
      DEST_DIR="${config.xdg.configHome}/skills/sources/anthropic-skills"
      CURRENT_LINK="$DEST_DIR/current"
      
      mkdir -p "$(dirname "$DEST_DIR")"
      
      if [ ! -d "$DEST_DIR/.git" ]; then
        git clone "$REPO_URL" "$DEST_DIR"
      else
        cd "$DEST_DIR"
        git fetch origin
        git reset --hard origin/main
      fi
      
      # Create symlink to current
      rm -f "$CURRENT_LINK"
      ln -sf "$DEST_DIR" "$CURRENT_LINK"
    '';
  };

  sync-humanizer = pkgs.writeShellApplication {
    name = "sync-humanizer";
    runtimeInputs = with pkgs; [git coreutils];
    text = ''
      set -euo pipefail
      REPO_URL="https://github.com/blader/humanizer"
      DEST_DIR="${config.xdg.configHome}/skills/sources/blader-humanizer"
      CURRENT_LINK="$DEST_DIR/current"
      
      mkdir -p "$(dirname "$DEST_DIR")"
      
      if [ ! -d "$DEST_DIR/.git" ]; then
        git clone "$REPO_URL" "$DEST_DIR"
      else
        cd "$DEST_DIR"
        git fetch origin
        git reset --hard origin/main
      fi
      
      # Create symlink to current
      rm -f "$CURRENT_LINK"
      ln -sf "$DEST_DIR" "$CURRENT_LINK"
    '';
  };
in {
  imports = [
    ./crush.nix
    ./opencode.nix
    ./mcp.nix
    ./lsp.nix
  ];

  options.ai-agents = with lib;
  with types; {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable the AI Agents module.";
      example = lib.literalExpression ''
        {
          enable = true;
          crush.enable = true;
          opencode.enable = false;
          mcp = {
            glean.enable = false;
            atlassian.enable = false;
          };
        }
      '';
    };

    skills-dir = mkOption {
      description = "Directory that has ai skills";
      type = path;
      default = config.xdg.configHome + "/skills/compiled";
    };
  };

  config = lib.mkIf cfg.enable {
    ai-agents.crush.enable = lib.mkDefault false;
    ai-agents.opencode.enable = lib.mkDefault true;
    xdg.configFile."opencode/skills".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.claude/skills";

    xdg.configFile."skills/sources/mine" = {
      source = ./skills;
      recursive = true;
    };

    home = {
      file.".claude/skills".source = config.lib.file.mkOutOfStoreSymlink cfg.skills-dir;
      packages = with pkgs; [
        uv # for uvx
        nodejs
      ];
    };

    programs = {
      claude-code = {
        mcpServers = cfg.mcpServers;
        enable = true;
      };

      fabric-ai = {
        enable = false;
        enableZshIntegration = true;
      };
    };

    # Custom git-sync implementation to support URIs on macOS
    # Home Manager's services.git-sync doesn't support URIs on Darwin
    # So we use custom launchd agents that call git-sync directly
    systemd.user = lib.mkIf pkgs.stdenv.isLinux {
      # Git sync services for Linux using simple git commands
      services.git-sync-anthropic-skills = {
        Unit.Description = "Git sync for anthropic-skills";
        Service = {
          Type = "oneshot";
          ExecStart = lib.getExe sync-anthropic-skills;
        };
      };
      
      services.git-sync-humanizer = {
        Unit.Description = "Git sync for humanizer";
        Service = {
          Type = "oneshot";
          ExecStart = lib.getExe sync-humanizer;
        };
      };

      # Timers for periodic sync
      timers.git-sync-anthropic-skills = {
        Unit.Description = "Git sync timer for anthropic-skills";
        Timer = {
          OnCalendar = "*:0/120"; # Every 2 hours
          Persistent = true;
        };
        Install.WantedBy = [ "timers.target" ];
      };
      
      timers.git-sync-humanizer = {
        Unit.Description = "Git sync timer for humanizer";
        Timer = {
          OnCalendar = "*:0/120"; # Every 2 hours  
          Persistent = true;
        };
        Install.WantedBy = [ "timers.target" ];
      };

      services.ai-skills = {
        Unit.Description = "Collect ai skills from different sources";
        Service = {
          Type = "oneshot";
          ExecStart = lib.getExe compile-ai-skills;
        };
      };
    };

    launchd.agents = lib.mkIf pkgs.stdenv.isDarwin {
      # Git sync agents for macOS using simple git commands
      git-sync-anthropic-skills = {
        enable = true;
        config = {
          Label = "git-sync-anthropic-skills";
          Program = lib.getExe sync-anthropic-skills;
          StartInterval = 7200; # 2 hours in seconds
          RunAtLoad = true;
        };
      };
      
      git-sync-humanizer = {
        enable = true;
        config = {
          Label = "git-sync-humanizer";
          Program = lib.getExe sync-humanizer;
          StartInterval = 7200; # 2 hours in seconds
          RunAtLoad = true;
        };
      };

      ai-skills-compiler = {
        enable = true;
        config = {
          Label = "ai-skills-compiler";
          Program = lib.getExe compile-ai-skills;
          RunAtLoad = true;
          WatchPaths = ["${config.xdg.configHome}/skills/sources"];
        };
      };
    };
  };
}
