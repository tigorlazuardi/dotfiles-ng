{
  config,
  user,
  lib,
  ...
}:
{
  networking.networkmanager.enable = true;
  networking.networkmanager.insertNameservers = lib.optional config.services.adguardhome.enable "192.168.100.5";
  users.users.${user.name}.extraGroups = [
    "networkmanager"
  ];
}
