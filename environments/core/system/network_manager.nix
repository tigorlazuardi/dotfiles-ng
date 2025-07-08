{
  config,
  user,
  lib,
  ...
}:
{
  networking.networkmanager.enable = true;
  networking.networkmanager.appendNameservers = lib.optional config.services.adguardhome.enable "192.168.100.5";
  users.users.${user.name}.extraGroups = [
    "networkmanager"
  ];
}
