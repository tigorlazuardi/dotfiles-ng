{ lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    libsixel # For displaying images in foot terminal
    foot
  ];
  programs.foot = {
    enable = true;
    server.enable = true;
    settings = {
      main.font = lib.mkDefault "0xProto Nerd Font Mono:size=12";
      colors.alpha = lib.mkForce 0.9;
      security.osc52 = "enabled";
      cursor.blink = true;
      main.selection-target = "both";
    };
  };
}
