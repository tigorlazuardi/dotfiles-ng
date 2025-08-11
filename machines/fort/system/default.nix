{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./syncthing.nix

    ../../../environments/core/system
  ]
  ++ (with inputs.nixos-hardware.nixosModules; [
    common-cpu-intel
    common-pc
    common-pc-ssd
  ]);
  boot.loader.systemd-boot = {
    enable = true;
    extraFiles = {
      # Disable the boot menu unless the user holds down a key
      "loader/loader.conf" = pkgs.writeText "loader.conf" ''
        timeout 0
      '';
    };
  };
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.printing = {
    enable = true;
    drivers = [ pkgs.brlaser ]; # Brother Laser Printer
  };
  hardware.sane = {
    enable = true;
    brscan4.enable = true; # Brother Scanner
    extraBackends = with pkgs; [ sane-airscan ];
  };
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      libvdpau-va-gl
    ];
  };

  powerManagement = {
    powertop.enable = true;
    cpuFreqGovernor = "powersave";
  };

  services.thermald.enable = true;

  services.tuned = {
    enable = true;
    settings.dynamic_tuning = true;
  };
}
