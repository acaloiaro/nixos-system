# Agent Guide for NixOS System Configuration

This repository contains NixOS and macOS (nix-darwin) configurations managed with Nix Flakes.

## Project Structure

- **`flake.nix`**: Entry point for all system configurations.
- **`systems/`**: Configuration for specific hosts.
  - `zw`, `jellybee`, `homebee`: NixOS systems.
  - `greenhouse` (hostname `JJTH7GH17J`): macOS system.
  - `pi`, `homepi`: Likely Raspberry Pi or similar ARM systems (some may be inactive in `flake.nix`).
- **`common/`**: Shared configurations, overlays, and Home Manager modules.
- **`images/`**: Configuration for generating system images.

## Key Commands

### Deployment
- **Install NixOS**: `nixos-install --flake .#<hostname>`
- **Rebuild NixOS**: `nixos-rebuild switch --flake .#<hostname>`
- **Rebuild macOS**: `darwin-rebuild switch --flake .#<hostname>`
- **Update Flakes**: `nix flake update`

### Provisioning
- **ZFS Setup**: Use `systems/<hostname>/nixos-zfs-setup.sh` (e.g., for `zw`) to partition disks and create ZFS pools before installation.
  - **Warning**: This script wipes disks. Read carefully before running.

## Configuration Patterns

### Modules & Options
- Custom Home Manager modules are defined in `common/home-manager` (e.g., `code`, `jira`).
- Modules often use `mkOption` to define enabling flags (e.g., `code.jujutsu.enable`).
- Shared system configuration is often imported via `imports` in host-specific `configuration.nix`.

### Secret Management
- **Tool**: `agenix` is used for encryption.
- **Files**: Secrets are stored as `.age` files in `systems/<hostname>/secrets/`.
- **Key**: Secrets are typically decrypted using SSH keys or dedicated key files.
- **Integration**: `homeage` is used for user-level secret management in Home Manager.

### Version Control
- **Jujutsu (jj)**: The user heavily utilizes `jj` alongside `git`.
- **Aliases**: `jj` aliases are configured in `common/home-manager/code/default.nix`.

## Gotchas

- **Empty Directories**: Some directories might seem empty but serve as mount points or future placeholders.
- **Hardware Specifics**:
  - `zw`: ThinkPad (x86_64)
  - `greenhouse`: MacBook Pro (M-series, aarch64)
- **Private Modules**: The flake inputs reference a private `greenhouse-nix-modules` repo. If you cannot access it, some evaluations might fail.
- **Impermanence**: Some systems use "impermanence" setup (root rollback on boot), configured in `nixos-zfs-setup.sh` and Nix modules.

## Development

- **Formatting**: No global formatter is enforced in `flake.nix` (only `nixpkgs-fmt` or `alejandra` are common in Nix, but check if installed).
- **Linter**: `statix` or `deadnix` are common but not explicitly seen in the root.
