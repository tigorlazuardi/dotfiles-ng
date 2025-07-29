{
  disko.devices = {
    disk = {
      os = {
        type = "disk";
        # Main NVME SSD
        device = "/dev/disk/by-id/nvme-PNY_CS2241_1TB_SSD_PNL04240437686500871";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              name = "ESP";
              start = "1M";
              end = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              size = "-20G";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ]; # Override existing partition
                subvolumes = {
                  "/home" = {
                    mountOptions = [ "compress=zstd" ];
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
                  "/varlib".mountpoint = "/var/lib";
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
            swappy = {
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
      adata = {
        type = "disk";
        # Secondary NVME. For storing games.
        device = "/dev/disk/by-id/nvme-ADATA_SX8200PNP_2L082L47182A";
        content = {
          type = "gpt";
          partitions = {
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ]; # Override existing partition
                subvolumes = {
                  "/root".mountpoint = "/adata";
                  # For snapper.
                  "/root/.snapshots" = { };
                };
              };
            };
          };
        };
      };
      kyo = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-K350-1TB_0004253001512";
        content = {
          type = "gpt";
          partitions = {
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ]; # Override existing partition
                subvolumes = {
                  "/root".mountpoint = "/kyo";
                  # For snapper.
                  "/root/.snapshots" = { };
                };
              };
            };
          };
        };
      };
      hgst = {
        type = "disk";
        device = "/dev/disk/by-id/ata-HGST_HTS721010A9E630_JR10004M3NZVHF";
        content = {
          type = "gpt";
          partitions = {
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ]; # Override existing partition
                subvolumes = {
                  "/root".mountpoint = "/kyo";
                  # For snapper.
                  "/root/.snapshots" = { };
                };
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
