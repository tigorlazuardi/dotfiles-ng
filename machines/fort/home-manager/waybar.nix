{ lib, ... }:
{
  programs.waybar.settings.main.height = lib.mkForce 1080;
}
