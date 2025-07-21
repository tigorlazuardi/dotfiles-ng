{
  inputs,
  ...
}:
{
  # see https://github.com/NixOS/nixos-hardware/blob/master/flake.nix for list of available hardware modules
  imports =
    with inputs.nixos-hardware.nixosModules;
    [
      ../../environments/core/system
    ]
    ++ (with inputs.nixos-hardware.nixosModules; [
      common-cpu-intel
      common-pc
      common-pc-ssd
    ]);
  boot.loader = {
    systemd-boot.enable = true;
    efi = {
      canTouchEfiVariables = true;
    };
  };

  networking.defaultGateway = "192.168.100.1";
  networking.interfaces.eth0 = {
    ipv4.addresses = [
      {
        address = "192.168.100.3";
        prefixLength = 24;
      }
      {
        address = "192.168.100.4";
        prefixLength = 24;
      }
      {
        address = "192.168.100.5";
        prefixLength = 24;
      }
    ];
  };
  # # TODO: Remove this when bindings are proper.
  # fileSystems."/var/lib/suwayomi-server" = {
  #   device = "/nas/services/suwayomi-server";
  #   fsType = "none";
  #   options = [ "bind" ];
  # };
}
