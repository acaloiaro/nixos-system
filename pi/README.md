# Raspberry Pi / Kodi

This system is not yet in its desired state. While it currently builds a working raspberrypi/kodi system, a few things 
are not ideal.

1. It's pinned to an arbitrary NixOS 23.05 version due to a confluence of bugs between home-manager, and hardware 
support for video acceleration and audio on raspberry pi. 
2. No home-manager, currently. That means the kodi keymap file has been manually put in place on the pi
3. Overall the config is pretty messy and could use a cleanup 
4. Not a flake 
5. Locked to arbitrary releases:

```bash
nix-channel --add https://github.com/NixOS/nixpkgs/archive/29339c1529b2c3d650d9cf529d7318ed997c149f.tar.gz nixos
nix-channel --add https://github.com/NixOS/nixos-hardware/archive/ca29e25c39b8e117d4d76a81f1e229824a9b3a26.tar.gz nixos-hardware
```
