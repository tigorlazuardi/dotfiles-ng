{ inputs, pkgs, ... }:
{
  imports = [
    inputs.stylix.nixosModules.stylix
  ];
  stylix = {
    enable = false;
    image = null;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/rose-pine.yaml";
    opacity = {
      applications = 0.6;
      desktop = 0.9;
      popups = 0.6;
      terminal = 0.9;
    };
  };
}
