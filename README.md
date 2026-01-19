# NixOS Systems

This repository manages the configuration for my personal and work infrastructure using [Nix Flakes](https://nixos.wiki/wiki/Flakes). It unifies system administration (NixOS, nix-darwin) and user environments (Home Manager) into a single, declarative codebase.

## Overview

- **`systems/`**: Contains host-specific configurations.
- **`common/`**: Shared modules, overlays, and configuration patterns.
- **`images/`**: Flake for generating installation media (e.g., SD card images).

## Active Systems

| Hostname | Type | Hardware | Description |
|----------|------|----------|-------------|
| **zw** | NixOS | IBM ThinkPad | Primary work laptop. Uses manual ZFS partitioning. |
| **greenhouse** | macOS | MacBook Pro | Work machine (Hostname: `JJTH7GH17J`). Managed via `nix-darwin`. |
| **homebee** | NixOS | Beelink Mini S12 | Home media server running Jellyfin. |
| **jellybee** | NixOS | Beelink U59 Pro | Mobile media server (RV) running Jellyfin. Uses `disko` for partitioning. |

> **Note:** older systems like `z1`, `pi`, and `homepi` are deprecated or inactive.

## Secret Management

Secrets are managed using `agenix` and `agenix-rekey`. The master private key is stored in `gopass` under the entry `systems/age.master`.

1. **Encrypt a new secret** using the master public key:
   ```bash
   echo "my-super-secret-password" | age -r age13sgljsr9srgxjxncl49qsn9dkkstcqct3ck9s7n2yu4lzelgp4uqcajgtj -o ./path/to/my-secret.age
   ```

2. **Add to Nix configuration:**
   ```nix
   age.secrets.my-secret = {
     rekeyFile = ./secrets/my-secret.age;
     # mode = "600"; # Optional, default is 400
     # owner = "root"; # Optional
   };
   ```

3. **Rekey for specific hosts:**
   This decrypts the secret using the master key (via `gopass`) and re-encrypts it for the target hosts.
   ```bash
   nix run .#rekey
   ```

## Installation

### Standard Install (e.g., `zw`)

1. Boot into a NixOS installer (official or custom image).
2. Run `sudo -i`.
3. Establish networking (see below).
4. Prepare storage:
   - For `zw`, use the script in `systems/zw/nixos-zfs-setup.sh`.
   - **Warning:** This will wipe the defined `DISK`.
5. Mount and generate config:
   ```bash
   nixos-generate-config --root /mnt
   ```
6. Install:
   ```bash
   nixos-install --flake .#zw
   ```

### Networking (Installer)

If using a minimal installer, you may need to manually configure Wi-Fi:

1. Start the supplicant: `systemctl start wpa_supplicant`
2. Run `wpa_cli`:
   ```text
   > add_network
   0
   > set_network 0 ssid "MY_SSID"
   OK
   > set_network 0 psk "MY_PASSWORD"
   OK
   > enable_network 0
   OK
   ```
