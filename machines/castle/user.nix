{
  inputs,
  user,
  pkgs,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];
  sops.age.keyFile = "/home/${user.name}/.config/sops/age/keys.txt";
  sops.defaultSopsFormat = "yaml";
  programs.nh.flake = "/home/${user.name}/dotfiles";

  home-manager.extraSpecialArgs = { inherit inputs; };
  home-manager.useGlobalPkgs = true;
  users.users.${user.name} = {
    isNormalUser = true;
    description = user.description;
    extraGroups = [
      "networkmanager"
      "wheel"
      # lp group is for printing
      "lp"
      # scanner group is for scanning
      "scanner"
    ];
    shell = pkgs.fish;
  };

  programs.fish.enable = true;

  nix.settings.trusted-users = [ user.name ];
}
