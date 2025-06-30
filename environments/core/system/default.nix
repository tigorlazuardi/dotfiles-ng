{
  lib,
  ...
}:
{
  imports = [
    ./editor.nix
    ./fonts.nix
    ./locale.nix
    ./nix_config.nix
    ./nix_index.nix
    ./programs.nix
    ./systemd.nix
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
