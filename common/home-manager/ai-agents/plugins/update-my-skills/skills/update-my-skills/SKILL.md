---
name: update-my-skills
description: Update an existing skill in the personal my-skills marketplace. Use when asked to update, edit, or modify a personal skill, or /update-my-skills.
argument-hint: "[skill-name] [description of changes]"
---

# Update My Skill

Modify an existing skill plugin in the `my-skills` marketplace.

## Marketplace location

The marketplace lives in the `nixos-system` repo (remote `github:acaloiaro/nixos-system`). Work in your local checkout — commonly `~/proj/nixos-system`, but confirm the path before writing. Inside that repo:

- Marketplace registry: `.claude-plugin/marketplace.json` (at the repo root)
- Plugin root: `common/home-manager/ai-agents/plugins/`

Note: the marketplace is resolved by Claude from GitHub, so edits are only picked up after they are committed and pushed (see step 6).

## Steps

### 1. Identify the skill

If no skill name is provided, list the available skills by reading `.claude-plugin/marketplace.json` and present them to the user.

If a skill name is provided, verify it exists under `common/home-manager/ai-agents/plugins/{skill-name}/`.

### 2. Read the current skill

Read these files (relative to the repo root):
- `common/home-manager/ai-agents/plugins/{skill-name}/.claude-plugin/plugin.json`
- `common/home-manager/ai-agents/plugins/{skill-name}/skills/{skill-name}/SKILL.md`

Present the current state to the user if they haven't specified what to change.

### 3. Apply changes

Based on user instructions, update the relevant files:

- **SKILL.md content changes**: Edit the skill instructions, workflows, or procedures. Keep it generic — no machine-specific absolute paths, no work-specific content.
- **Description changes**: Update the `description` field in all three:
  - `common/home-manager/ai-agents/plugins/{skill-name}/.claude-plugin/plugin.json`
  - The YAML frontmatter in `SKILL.md`
  - The corresponding entry in `.claude-plugin/marketplace.json`
- **Name changes** (rename): This requires:
  1. Creating the new plugin directory structure under `common/home-manager/ai-agents/plugins/{new-name}/`
  2. Moving content to the new location
  3. Updating `plugin.json`, `SKILL.md` frontmatter, and `marketplace.json`
  4. Updating `enabledPlugins` (old → new) in each consuming system's Claude Code config
  5. Removing the old directory

### 4. Version bump

When updating a skill, bump the patch version (e.g., `1.0.0` → `1.0.1`) in both:
- `common/home-manager/ai-agents/plugins/{skill-name}/.claude-plugin/plugin.json`
- The matching entry in `.claude-plugin/marketplace.json`

### 5. Confirm

Show the user a diff or summary of what changed.

### 6. Commit, push, and rebuild

After the user confirms the changes:

1. Create a jujutsu change in the `nixos-system` repo with a descriptive message (e.g., `feat: update {skill-name} skill — <brief summary>`) — use the `version-control` skill's jj workflow, never `git`.
2. `jj git push` so the GitHub-sourced marketplace picks up the change.
3. Remind the user to rebuild the nix config on each system that enables the skill for the updated version to take effect.
