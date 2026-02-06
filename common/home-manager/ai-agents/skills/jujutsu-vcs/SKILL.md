---
name: jujutsu-vcs
description: Version control workflow using jujutsu (jj) exclusively. Use when managing version control, committing changes, viewing history, working with bookmarks, rebasing, squashing, or syncing with remote repositories. DO NOT use git commands - use jj commands instead. Jujutsu uses bookmarks (not branches), changes (not commits), and has automatic working copy snapshotting.
---

# Jujutsu Version Control

> **Note**: This documentation is current as of jujutsu version **0.37.0**. Run `jj --version` to check your version and `jj help` for the latest command reference.

**Forget everything you know about git.**

Use jujutsu exclusively. NEVER use git commands.

## Key Concepts

- `@` is the working copy (current change)
- `@-` is the parent of working copy
- Jujutsu uses **bookmarks** (not branches)
- Jujutsu uses **changes** (not commits)
- Working copy is automatically snapshotted (no staging area)
- Changes are immutable; rewriting creates new change IDs

## Common Workflows

### Make Changes and Push

```bash
# Make your changes to files (automatically snapshotted)
jj describe -m "your commit message"
jj bookmark create your-bookmark-name
jj git push
```

### Start New Work from Main

```bash
jj git fetch
jj new main
# Make changes...
jj describe -m "message"
jj bookmark create feature-name
jj git push
```

### Update Before Pushing

```bash
jj git fetch
jj rebase -d main
jj git push
```

### Address PR Review Comments

```bash
jj new your-bookmark
# Make fixes...
jj describe -m "address review comments"
jj bookmark move your-bookmark --to @
jj git push
```

### Squash Fixes into Parent

```bash
jj new @-          # Create change on parent
# Make fixes...
jj squash          # Squash into parent
```

## Command Reference

### Status & Inspection

```bash
jj status              # View working copy status (alias: jj st)
jj log                 # View history
jj log -r '@::'        # View @ and descendants
jj diff                # View changes in @
jj diff -r @-          # View changes in parent
jj show                # Show current change details
```

### Making Changes

```bash
jj describe -m "msg"   # Set description for @
jj new                 # Create new empty change on top of @
jj new main            # Create new change on top of main
jj new -m "msg"        # Create new change with description
jj commit -m "msg"     # Describe @ and create new change on top
```

### Bookmark Operations

```bash
jj bookmark create name              # Create bookmark at @ (alias: jj b c)
jj bookmark rename OLD NEW           # Rename bookmark (alias: jj b r)
jj bookmark move name --to REV       # Move bookmark to revision (alias: jj b m)
jj bookmark delete name              # Delete bookmark (alias: jj b d)
jj bookmark list                     # List all bookmarks (alias: jj b l)
jj bookmark track name --remote origin  # Track remote bookmark (alias: jj b t)
```

For complete bookmark reference, see [references/bookmarks.md](references/bookmarks.md).

### History Rewriting

```bash
jj squash                   # Squash @ into parent
jj squash -r REV            # Squash REV into its parent
jj squash --into REV        # Squash @ into specified revision
jj split                    # Split current change interactively
jj abandon                  # Abandon current change
jj abandon REV              # Abandon specified revision
```

### Rebasing

```bash
jj rebase -d main           # Rebase current branch onto main
jj rebase -d main@origin    # Rebase onto remote main
jj rebase -b @ -d main      # Rebase branch containing @ onto main
jj rebase -r @ -d main      # Rebase only @ (not descendants)
```

### Remote Operations

```bash
jj git fetch                     # Fetch from all remotes
jj git push                      # Push tracked bookmarks (default)
jj git push --bookmark name      # Push specific bookmark
jj git push --deleted            # Push all deleted bookmarks
jj git push --dry-run            # Preview what will be pushed
jj git remote list               # List remotes
```

**Renaming Bookmarks with Remote**:

```bash
jj bookmark rename old-name new-name  # Rename locally
jj git push --bookmark new-name       # Push new name
jj git push --deleted                 # Delete old name from remote
```

For complete git push reference, see [references/git-push.md](references/git-push.md).

## Revset Basics

Common revset expressions:

| Expression    | Description                        |
| ------------- | ---------------------------------- |
| `@`           | Working copy                       |
| `@-`          | Parent of @                        |
| `@--`         | Grandparent of @                   |
| `main`        | Bookmark named "main"              |
| `main@origin` | Remote tracking bookmark           |
| `x..y`        | Ancestors of y, not ancestors of x |
| `::x`         | x and all ancestors                |
| `x::`         | x and all descendants              |

For complete revset syntax, see [references/revsets.md](references/revsets.md) or run `jj help -k revsets`.

## Important Notes

- `jj edit` is discouraged; prefer `jj new` + `jj squash`
- Working copy is always automatically snapshotted
- Use `jj help <command>` for detailed command help
- Use `jj help -k <keyword>` for topic help (e.g., `jj help -k revsets`)

## Detailed References

For exhaustive command documentation, see:

- [references/commands.md](references/commands.md) - Complete list of all commands and subcommands
- [references/bookmarks.md](references/bookmarks.md) - Complete bookmark command reference
- [references/git-push.md](references/git-push.md) - Complete git push command reference
- [references/revsets.md](references/revsets.md) - Complete revset syntax reference
