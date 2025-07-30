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
                extraArgs = [ "-f" ]; # Override existing partition
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
                  "/root" = {
                    mountpoint = "/adata";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
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
                  "/root" = {
                    mountpoint = "/kyo";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
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
        # 1TB Spinning disk. For storing backups.
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
                  "/root" = {
                    mountpoint = "/hgst";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  # For snapper.
                  "/root/.snapshots" = { };
                };
              };
            };
          };
        };
      };
      vgen = {
        type = "disk";
        # 512GB SATA SSD.
        device = "/dev/disk/by-id/ata-V-GEN05SM23AR512INT_512GB_VGAR2023053000068434";
        content = {
          type = "gpt";
          partitions = {
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ]; # Override existing partition
                subvolumes = {
                  "/root" = {
                    mountpoint = "/hgst";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  # For snapper.
                  "/root/.snapshots" = { };
                };
              };
            };
          };
        };
      };
      wdc = {
        type = "disk";
        # 500GB SATA SSD.
        device = "/dev/disk/by-id/ata-WDC_WDS500G2B0A-00SM50_19432C802119";
        content = {
          type = "gpt";
          partitions = {
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ]; # Override existing partition
                subvolumes = {
                  "/root" = {
                    mountpoint = "/wdc";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
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
