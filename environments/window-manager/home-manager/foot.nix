{ lib, ... }:
{
  programs.foot = {
    enable = true;
    server.enable = true;
    settings = {
      colors.alpha = lib.mkForce 0.9;
      security.osc52 = "enabled";
      cursor.blink = true;
    };
  };
}
