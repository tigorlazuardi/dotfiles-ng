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
    age.keyFile = "/sops/keys.txt";
    defaultSopsFormat = "yaml";
  };
}
