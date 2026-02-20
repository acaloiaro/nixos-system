# Personal override layer for ai-agents (module definition comes from greenhouse-nix-modules).
#
# This file sets option values and adds personal skill sources / local skills
# on top of the base ai-agents module.
{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.ai-agents.enable {
    # Personal skill sources (in addition to the defaults from greenhouse-nix-modules)
    ai-agents.opencode.enable = true;
    ai-agents.mcp.github.enable = true;
    ai-agents.skillSources = [
      {
        name = "juan-skills";
        url = "https://github.com/grnhse/nix-configs-jcmuller.git";
        excludedSkills = ["jira-ticket-creation"];
      }
    ];

    # Deploy personal local skills (general-code-style, etc.)
    xdg.configFile."skills/sources/personal" = {
      source = ./skills;
      recursive = true;
    };
  };
}
