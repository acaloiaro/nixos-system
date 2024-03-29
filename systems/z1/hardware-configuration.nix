# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "z1data/nixos";
      fsType = "zfs"; options = [ "zfsutil" "X-mount.mkdir" ];
      neededForBoot = true;
    };

  fileSystems."/home" =
    { device = "z1data/nixos/home";
      fsType = "zfs"; options = [ "zfsutil" "X-mount.mkdir" ];
      neededForBoot = true;
    };

  fileSystems."/nix" =
    { device = "z1data/nixos/nix";
      fsType = "zfs"; options = [ "zfsutil" "X-mount.mkdir" ];
    };

  fileSystems."/root" =
    { device = "z1data/nixos/root";
      fsType = "zfs"; options = [ "zfsutil" "X-mount.mkdir" ];
      neededForBoot = true;
    };

  fileSystems."/usr" =
    { device = "z1data/nixos/usr";
      fsType = "zfs"; options = [ "zfsutil" "X-mount.mkdir" ];
    };

  fileSystems."/var" =
    { device = "z1data/nixos/var";
      fsType = "zfs"; options = [ "zfsutil" "X-mount.mkdir" ];
    };

  fileSystems."/boot" =
    { device = "z1boot/nixos/boot";
      fsType = "zfs"; options = [ "zfsutil" "X-mount.mkdir" ];
      neededForBoot = true;
    };

  fileSystems."/boot/efis/z1-efi-boot0" =
    { device = "/dev/disk/by-partlabel/z1-efi-boot0";
      fsType = "vfat";
    };

  fileSystems."/boot/efi" =
    { device = "/boot/efis/z1-efi-boot0";
      fsType = "none";
      options = [ "bind" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-partlabel/z1swap0"; }
    ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  networking.interfaces.enp38s0f1.useDHCP = lib.mkDefault true;
  networking.interfaces.wlp0s20f3.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
