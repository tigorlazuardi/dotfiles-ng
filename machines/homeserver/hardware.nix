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
    label = "NIXROOT";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    label = "NIXBOOT";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };
  # fileSystems."/var/lib" = {
  #   label = "VARLIB";
  #   fsType = "ext4";
  # };

  fileSystems."/nas" = {
    label = "WD_RED_4T_1";
    fsType = "ext4";
  };

  fileSystems."/wolf" = {
    label = "WOLF_4T_1";
    fsType = "ext4";
  };

  swapDevices = [
    { label = "NIXSWAP"; }
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
