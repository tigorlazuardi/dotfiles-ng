{ inputs, ... }:
{
  imports = [

    ./user.nix

    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    useGlobalPkgs = true;
  };

  sops.age.keyFile = "/home/homeserver/.config/sops/age/keys.txt";
  networking.hostName = "homeserver";
  programs.nh.flake = "/home/tigor/dotfiles";
  system.stateVersion = "24.05";
}
