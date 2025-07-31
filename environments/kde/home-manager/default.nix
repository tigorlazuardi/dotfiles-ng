{
  inputs,
  ...
}:
{
  imports = [
    inputs.plasma-manager.homeManagerModules.plasma-manager

    # Generate by running from the root of the repository:
    #
    # nix run github:nix-community/plasma-manager > environments/kde/home-manager/plasma-manager.nix
    ./plasma-manager.nix
  ];
}
