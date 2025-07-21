{
  config,
  pkgs,
  inputs,
  user,
  ...
}:
{
  imports =
    [
      ../../environments/core/system
    ]
    ++ (with inputs.nixos-hardware.nixosModules; [
      common-cpu-amd
      common-gpu-amd
      common-pc
      common-pc-ssd
    ]);
  # boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader = {
    efi = {
      efiSysMountPoint = "/boot";
      canTouchEfiVariables = true;
    };
    grub = {
      enable = true;
      efiSupport = true;
      useOSProber = true;
      device = "nodev"; # used nodev because of efi support
    };
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  sops.secrets."smb/credentials/homeserver".sopsFile = ../../secrets/smb.yaml;
  services.printing = {
    enable = true;
    drivers = [ pkgs.brlaser ]; # Brother Laser Printer
  };
  hardware.sane = {
    enable = true;
    brscan4.enable = true; # Brother Scanner
    extraBackends = with pkgs; [ sane-airscan ];
  };
  users.users.${user.name}.extraGroups = [
    "scanner" # For sane scanner access
    "lp" # For printer access
  ];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      amdvlk
    ];
  };
  system.fsPackages = [
    pkgs.bindfs
    pkgs.cifs-utils
  ];
  fileSystems."/nas" = {
    device = "//192.168.100.5/nas";
    fsType = "cifs";
    options = [
      "_netdev"
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=60"
      "x-systemd.device-timeout=5s"
      "x-systemd.mount-timeout=5s"
      "uid=1000"
      "gid=1000"
      "credentials=${config.sops.secrets."smb/credentials/homeserver".path}"
    ];
  };

  fileSystems."/wolf" = {
    device = "//192.168.100.5/wolf";
    fsType = "cifs";
    options = [
      "_netdev"
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=60"
      "x-systemd.device-timeout=5s"
      "x-systemd.mount-timeout=5s"
      "uid=1000"
      "gid=1000"
      "credentials=${config.sops.secrets."smb/credentials/homeserver".path}"
    ];
  };
}
