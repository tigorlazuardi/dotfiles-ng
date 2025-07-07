{ inputs, pkgs, ... }:
{
  imports = [
    inputs.stylix.nixosModules.stylix
  ];
  stylix = {
    enable = true;
    image = null;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/rose-pine.yaml";
    targets.nixvim.enable = false;
  };
}
