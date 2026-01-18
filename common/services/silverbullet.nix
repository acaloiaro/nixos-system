{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.services.silverbullet;
in {
  imports = [
    ../services/tailscale-serve.nix
  ];

  options.my.services.silverbullet = {
    enable = mkEnableOption "Enable Silverbullet Server";
    dataDir = mkOption {
      type = types.str;
      description = "The location on disk where data is stored";
    };
  };

  config = mkIf cfg.enable {
    age = {
      secrets = {
        opencloud_app_key = {
          # TODO: move this secret out of jellybee's system dir
          file = ../../systems/jellybee/secrets/opencloud_app_key.age;
          owner = "silverbullet";
          group = "silverbullet";
        };
      };
    };

    services.silverbullet = {
      enable = true;
      user = "silverbullet";
      listenAddress = "100.99.204.21";
      spaceDir = cfg.dataDir;
      envFile = "/etc/silverbullet/env";
    };

    # Use the new tailscale-serve module
    services.tailscale-serve = {
      enable = true;
      services.silverbullet = {
        mappings = {
          http = {
            port = 3000;
            backend = "100.99.204.21:3000";
          };
        };
      };
    };

    # Make the home page `Home` instead of `index`
    environment = {
      etc."silverbullet/env".text = ''
        SB_INDEX_PAGE=Home
      '';

      # Configure davfs2
      etc."davfs2/davfs2.conf".text = ''
        ask_auth 0
        use_locks 0
      '';

      # Perform Basic web-dav auth with this entry of the form
      # <URL> username password
      #
      # Each entry in this file is separated by a newline
      etc."davfs2/secrets" = {
        source = config.age.secrets.opencloud_app_key.path;
        mode = "0600";
      };
    };

    users = {
      groups = {
        "davfs2" = {};
      };
      users.davfs2 = {
        isSystemUser = true;
        group = "davfs2";
      };

      users.silverbullet = {
        isSystemUser = true;
        group = "silverbullet";
        home = "/mnt/opencloud/adriano";
        createHome = true;
      };
    };
    environment.systemPackages = with pkgs; [
      davfs2
    ];

    # WebDAV mount for silverbullet
    systemd.services.opencloud-webdav-mount = {
      description = "Mount OpenCloud WebDAV for Silverbullet";
      after = ["network-online.target" "opencloud.service"];
      wants = ["network-online.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = "root";
        ExecStartPre = [
          "${pkgs.coreutils}/bin/mkdir -p /mnt/opencloud/adriano"
          "${pkgs.coreutils}/bin/chown silverbullet:silverbullet /mnt/opencloud/adriano"
        ];
        ExecStart = "${pkgs.mount}/bin/mount -t davfs https://jellybee.bison-lizard.ts.net:9200/remote.php/dav/spaces/094a577f-1bfd-483e-ae2a-d277cb24bb11$baa79013-0ccf-4ab1-ad5c-45299685c50f /mnt/opencloud/adriano -o uid=silverbullet,gid=users,file_mode=0664,dir_mode=0775,conf=/etc/davfs2/davfs2.conf";
        ExecStop = "${pkgs.umount}/bin/umount /mnt/home/adriano";
      };
    };

    # Ensure silverbullet starts after the mount
    systemd.services.silverbullet = {
      after = ["opencloud-webdav-mount.service"];
      requires = ["opencloud-webdav-mount.service"];
    };
  };
}
