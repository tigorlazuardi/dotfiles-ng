{ nixpkgs, ... }@inputs:
let
  mkNixosConfiguration =
    { module, user }:
    nixpkgs.lib.nixosSystem {
      modules = [
        module
      ];
      specialArgs = { inherit inputs user; };
    };
in
{
  nixosConfigurations = {
    castle = mkNixosConfiguration {
      module = ./castle;
      user = {
        name = "tigor";
        description = "Tigor Hutasuhut";
      };
    };
    homeserver = mkNixosConfiguration {
      module = ./homeserver;
      user = {
        name = "homeserver";
        description = "Homeserver";
      };
    };
  };
}
