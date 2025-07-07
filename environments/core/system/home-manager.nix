{ inputs, user, ... }:
let
  inherit (inputs) home-manager;
in
{
  imports = [
    home-manager.nixosModules.home-manager
  ];
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = ".bak";
    extraSpecialArgs = {
      inherit inputs;
      inherit user;
    };
  };
}
