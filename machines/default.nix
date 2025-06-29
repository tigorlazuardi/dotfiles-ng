{ nixpkgs, ... }@inputs:
let
  mkNixosConfiguration =
    machine:
    nixpkgs.lib.nixosSystem {
      modules = [
        machine
        ./_common
      ];
      specialArgs = { inherit inputs; };
    };
in
{
  nixosConfigurations = {
    castle = mkNixosConfiguration ./castle;
    homeserver = mkNixosConfiguration ./homeserver;
  };
}
