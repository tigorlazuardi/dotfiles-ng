{ inputs, user, ... }:
let
  inherit (inputs) home-manager;
in
{
  imports = [
    home-manager.nixosModules.home-manager
  ];
  # Required for xdg portals in home manager to work
  environment.pathsToLink = [
    "/share/xdg-desktop-portal"
    "/share/applications"
  ];
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "bak";
    extraSpecialArgs = {
      inherit inputs;
      inherit user;
    };
  };
}
