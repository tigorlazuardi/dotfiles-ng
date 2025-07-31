{
  lib,
  ...
}:
{
  imports = [
    ./editor.nix
    ./fonts.nix
    ./home-manager.nix
    ./locale.nix
    ./network_manager.nix
    ./networking.nix
    ./nh.nix
    ./nix_config.nix
    ./nix_index.nix
    ./podman.nix
    ./programs.nix
    ./sops.nix
    ./systemd.nix
    ./user.nix
    ./utils.nix
    ./wireguard.nix
    ./zoxide.nix
  ];
  time.timeZone = lib.mkDefault "Asia/Jakarta";
  documentation.enable = true;
  documentation.man = {
    man-db.enable = false;
    generateCaches = true;
    mandoc.enable = true;
  };

  services.dbus.implementation = "broker";
}
