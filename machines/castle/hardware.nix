{
  config,
  lib,
  modulesPath,
  ...
}:
{
  # Import configurations from nix-community recommended settings.
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usbhid"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/6a987bc7-1f00-4494-bcef-b0f8afc62b7b";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/812C-A3A9";
    fsType = "vfat";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/0add1f95-4cd5-4d44-876e-c1b381b7d133";
    fsType = "ext4";
  };

  fileSystems."/workstation" = {
    device = "/dev/disk/by-uuid/7a3a7a8a-91d5-43fb-a80b-376bacdb54ec";
    fsType = "ext4";
  };

  swapDevices = [ { device = "/dev/disk/by-uuid/15139a5f-a695-47a1-bd59-7e530989860c"; } ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
