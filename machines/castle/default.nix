{ inputs, ... }:
{
  imports = [
    ./hardware.nix
    ./user.nix

    ../../system/core

    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager.extraSpecialArgs = { inherit inputs; };
  home-manager.useGlobalPkgs = true;

  sops.age.keyFile = "/home/tigor/.config/sops/age/keys.txt";

  networking.hostName = "castle";

  programs.nh.flake = "/home/tigor/dotfiles";

  system.stateVersion = "23.11";
  # environment.variables.GSK_RENDERER = "ngl";
}
