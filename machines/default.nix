{ nixpkgs, ... }@inputs:
let
  mkNixosConfiguration =
    machine:
    nixpkgs.lib.nixosSystem {
      modules = [
        machine
      ];
      specialArgs = { inherit inputs; };
    };
in
{
  nixosConfigurations = {
    castle = mkNixosConfiguration ./castle;
  };
}
