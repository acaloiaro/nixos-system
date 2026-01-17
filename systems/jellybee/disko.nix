{ lib, ... }: {
  disko.devices = {
    disk = {
      main = {
        device = "/dev/sdc";
        type = "disk";
        content = {
          type = "zfs";
          pool = "opencloud";
        };
      };
    };
    zpool = {
      opencloud = {
        type = "zpool";
        rootFsOptions = {
          compression = "zstd";
          "com.sun:auto-snapshot" = "true";
        };
        mountpoint = "/opencloud";
      };
    };
  };
}
