{...}: {
  boot.supportedFilesystems = ["zfs" "ntfs"];
  networking.hostId = "8315ed6e";

  # Boot
  boot.zfs.devNodes = "/dev/disk/by-partlabel";
  boot.zfs.forceImportRoot = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.generationsDir.copyKernels = true;

  # Services
  services.zfs.autoScrub.enable = true;
}
