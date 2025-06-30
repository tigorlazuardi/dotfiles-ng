{ inputs, ... }:
{
  imports = [
    ./hardware.nix
    ./system.nix
    ./user.nix
  ];

  networking.hostName = "castle";
  system.stateVersion = "23.11";
  # environment.variables.GSK_RENDERER = "ngl";
}
