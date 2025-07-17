{ pkgs, ... }:
{
  home.packages = with pkgs; [
    godot
  ];
  programs.git.lfs.enable = true;
}
