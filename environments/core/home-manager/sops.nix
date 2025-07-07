{
  config,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];
  home.packages = with pkgs; [ sops ];
  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFormat = "yaml";
  };
}
