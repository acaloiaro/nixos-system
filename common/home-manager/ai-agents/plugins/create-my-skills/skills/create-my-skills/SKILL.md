---
name: create-my-skills
description: Scaffold a new skill plugin in the personal my-skills marketplace. Use when asked to create a personal skill, add a new skill, or /create-my-skills.
argument-hint: "[skill-name] [description of what the skill should do]"
---

# Create My Skill

Create a new skill plugin in the `my-skills` marketplace. These skills are system-agnostic and shared across every machine, so they live in the `nixos-system` repo and **must contain no machine-specific absolute paths or work-specific content**.

## Marketplace location

The marketplace lives in the `nixos-system` repo (remote `github:acaloiaro/nixos-system`). Work in your local checkout — commonly `~/proj/nixos-system`, but confirm the path before writing. Inside that repo:

- Marketplace registry: `.claude-plugin/marketplace.json` (at the repo root)
- Plugin root: `common/home-manager/ai-agents/plugins/`

Note: the marketplace is resolved by Claude from GitHub, so a new skill is only installable after it is committed and pushed (see step 7).

## Steps

### 1. Gather information

Ask the user for (if not provided as arguments):
- **Skill name**: kebab-case identifier (e.g., `my-cool-skill`)
- **Description**: What the skill does and when Claude should use it
- **Skill content**: The instructions, workflows, or procedures the skill should contain

### 2. Create the plugin directory structure

Relative to the `nixos-system` repo root:

```
common/home-manager/ai-agents/plugins/{skill-name}/
├── .claude-plugin/
│   └── plugin.json
└── skills/
    └── {skill-name}/
        └── SKILL.md
```

### 3. Write `.claude-plugin/plugin.json`

```json
{
  "name": "{skill-name}",
  "description": "{short description}",
  "version": "1.0.0"
}
```

### 4. Write `skills/{skill-name}/SKILL.md`

Use this template:

```markdown
---
name: {skill-name}
description: {description — be specific about when Claude should invoke this skill}
---

{skill content}
```

Guidelines for the SKILL.md:
- Write clear, procedural instructions that Claude can follow.
- Include specific tool/CLI commands where applicable.
- Add edge case handling for common failure modes.
- Keep instructions actionable — avoid vague guidance.
- **Stay generic.** No machine-specific absolute paths (no `/Users/...` or `/home/...`), no work-specific identifiers. This marketplace is shared across all systems.

### 5. Register in marketplace.json

Read the current `.claude-plugin/marketplace.json`, then append a new entry to the `plugins` array:

```json
{
  "name": "{skill-name}",
  "source": "./common/home-manager/ai-agents/plugins/{skill-name}",
  "description": "{short description}",
  "version": "1.0.0"
}
```

### 6. Enable the plugin per consuming system

Each machine that should load the skill enables it in its own `programs.claude-code.settings.enabledPlugins`, in `plugin@marketplace` form:

```nix
"{skill-name}@my-skills" = true;
```

The marketplace itself must also be known to that machine (usually already configured once):

```nix
extraKnownMarketplaces.my-skills.source = {
  source = "github";
  repo = "acaloiaro/nixos-system";
};
```

- On `nixos-system` machines, that config lives in the system's home file (e.g. `systems/zw/home/adriano.nix`).
- On any other machine, it lives in that machine's own Claude Code config.

Ask the user which systems should get the new skill, and edit each one's `enabledPlugins`.

### 7. Commit, push, and rebuild

After the user confirms:

1. Create a jujutsu change in the `nixos-system` repo with a descriptive message (e.g., `feat: add {skill-name} skill`) — use the `version-control` skill's jj workflow, never `git`.
2. `jj git push` so the GitHub-sourced marketplace picks up the new plugin.
3. Remind the user to rebuild the nix config on each system where the plugin was enabled for the `enabledPlugins` change to take effect.

### 8. Confirm

Show the user a summary of what was created and where it was enabled.
