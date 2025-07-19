{ pkgs, ... }:
{
  home.packages = with pkgs; [
    godot
    gdtoolkit_4
  ];
  programs.git.lfs.enable = true;
}
