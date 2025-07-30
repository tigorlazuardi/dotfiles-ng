{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-SKHynix_HFM512GD3HX015N_FYA8N050111208Q0F";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            sops = {
              size = "256M";
              name = "sops";
              priority = 2;
              content = {
                type = "filesystem";
                format = "ext4";
                mountpunt = "/sops";
              };
            };
            root = {
              size = "-20G";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes = {
                  "/home" = {
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                    mountpoint = "/home";
                  };
                  # For snapper.
                  "/home/.snapshots" = { };
                  "/nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  # We do have to persist /var/lib so programs can store state there between boot.
                  "/varlib" = {
                    mountpoint = "/var/lib";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  # For snapper.
                  "/varlib/.snapshots" = { };
                  # Just in case we need to debug stuffs between boot.
                  "/varlog" = {
                    mountpoint = "/var/log";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                };
              };
            };
            swap = {
              size = "100%";
              content = {
                type = "swap";
                discardPolicy = "both";
                resumeDevice = true;
              };
            };
          };
        };
      };
    };
    # Impermanence. Root will be wiped on reboot.
    #
    # Ensure to mount directories that need to persist on above.
    nodev = {
      "/" = {
        fsType = "tmpfs";
        mountOptions = [ "size=256M" ];
      };
    };
  };
}
