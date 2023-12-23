# NixOS dotfiles 

These dotfiles initialize my primary system 'z1', and various raspberry PIs.

# Install

- Boot into a NixOS install USB stick/CD/DVD
- At the install terminal, run `sudo -i`
- Make this directory available to your installer, either by putting it on a separate usb drive, separate disk, or cloning the repo to the installer ramdisk.
- Open `nixos-zfs-setup.sh` and modify it to your liking, paying special attention to the `DISK` variable. This should match the disk on which NixOS will be installed. It is also the disk on which the `esp` is installed. !!IF THERE IS ALREADY AN OS ON `DISK`, IT WILL BE WIPED OUT IN THE NEXT STEP!!
- nixos-generate-config --root /mnt 
- Run `bash nixos-zfs-setup.sh`
- Add private keys corresponding with the public keys that encrypted the system's secrets to `/mnt/root/.ssh`
- Copy our custom configs to where the installer will use them: `cp -rf * /mnt/etc/nixos`
- `cd /mnt/etc/nixos`
- Install NixOS on the system: `nixos-install --flake .#z1`
- `umount -Rl /mnt && swapoff -a && zpool export -a && reboot`

# Rescue / Install help

Boot into the NixOS installer usb/CD/DVD.

**Wireless Networking**

To get wireless networking, `wpa_supplicant` must be started. 

`systemctl start wpa_supplicant`

After starting wpa_supplicant, start `wpa_cli`:

```
add_network
set_network 0 ssid "<YOUR SSID>"
set network 0 psk "<Your wifi password"
set network 0 key_mgmt WPA-PSK | NONE | <WHATEVER TYPE YOUR NETWORK USES>
enable_network 0

```

**Rebuilding from rescue**

It _may_ be possible to perform `nixos-rebuild --flake .#z1` from the following environment, but doing so is currentlyl untested. 

```bash
zpool import -alf -R /mnt 
nixos-enter --root /mnt
```

**Add `NIXOS_INSTALL_BOOTLOADER=1` to rescue from bootloader issues if running `nixos-rebuild`.
