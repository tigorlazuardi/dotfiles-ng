{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "vmd"
    "xhci_pci"
    "ahci"
    "nvme"
    "usbhid"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/439a1beb-1443-495b-9891-012605819803";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/47A1-0296";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  fileSystems."/nas" = {
    device = "/dev/disk/by-uuid/d52cfbb5-ccc1-4c2f-b4e3-3b10e0fcd89d";
    fsType = "ext4";
  };

  fileSystems."/wolf" = {
    device = "/dev/disk/by-uuid/b0bc7a97-8e9e-451e-b02f-16abf9ef8afd";
    fsType = "ext4";
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/12cf0e83-d177-4992-b7b2-857a6dfcc5df"; }
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.enableRedistributableFirmware = true;
  hardware.graphics.enable = true;
  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver
    libvdpau-va-gl
  ];
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };

  # Allow disks to spin down.
  services.udev.extraRules =
    let
      mkRule = as: lib.concatStringsSep ", " as;
      mkRules = rs: lib.concatStringsSep "\n" rs;
    in
    mkRules [
      (mkRule [
        ''ACTION=="add|change"''
        ''SUBSYSTEM=="block"''
        ''KERNEL=="sd[a-z]"''
        ''ATTR{queue/rotational}=="1"''
        ''RUN+="${pkgs.hdparm}/bin/hdparm -B 90 -S 41 /dev/%k"''
      ])
    ];
}
