{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.sfos.incus;
in {
  options.sfos.incus.enable = mkEnableOption "enable incus";
  options.sfos.incus.package = mkOption {
    type = with types; str;
    description = "The incus package to use, e.g. 'incus' or 'incus-lts'";
    default = [pkgs.incus];
  };
  options.sfos.incus.admin-users = mkOption {
    type = with types; listOf str;
    description = "A list of system users who are incus admins";
    default = [];
  };

  config = mkIf cfg.enable {
    virtualisation = {
      incus = {
        ui.enable = true;
        enable = true;
        package = pkgs.incus;
        # Setup the incus cluster
        preseed = {
          config = {
            "core.https_address" = ":8443";
            "images.auto_update_interval" = 15;
          };
          networks = [
            {
              config = {
                "ipv4.nat" = "true";
              };
              name = "incusbr0";
              type = "bridge";
            }
          ];
          profiles = [
            {
              devices = {
                eth0 = {
                  name = "eth0";
                  network = "incusbr0";
                  type = "nic";
                };
                root = {
                  path = "/";
                  pool = "default";
                  size = "10GiB";
                  type = "disk";
                };
              };
              name = "default";
            }
          ];
          storage_pools = [
            {
              config = {
                source = "/var/lib/incus/storage-pools/default";
              };
              driver = "dir";
              name = "default";
            }
          ];
        };
      };
    };

    networking.firewall = {
      interfaces.incusbr0.allowedTCPPorts = [
        22
        53
        67
      ];
      interfaces.incusbr0.allowedUDPPorts = [
        53
        67
      ];
    };

    # Add users as incus admins
    users.groups."incus-admin" = mkIf (cfg.admin-users != []) {members = cfg.admin-users;};
  };
}
