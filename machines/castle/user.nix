{ inputs, pkgs, ... }:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];
  sops.age.keyFile = "/home/tigor/.config/sops/age/keys.txt";
  sops.defaultSopsFormat = "yaml";
  programs.nh.flake = "/home/tigor/dotfiles";

  home-manager.extraSpecialArgs = { inherit inputs; };
  home-manager.useGlobalPkgs = true;
  users.users.tigor = {
    isNormalUser = true;
    description = "Tigor Hutasuhut";
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

  nix.settings.trusted-users = [ "tigor" ];
}
