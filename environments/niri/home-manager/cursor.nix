{ pkgs, ... }:
{
  gtk.cursorTheme = {
    package = pkgs.borealis-cursors;
    name = "Borealis-cursors";
  };
  programs.niri.settings.cursor = {
    xcursor-theme = "Borealis-cursors";
  };
}
