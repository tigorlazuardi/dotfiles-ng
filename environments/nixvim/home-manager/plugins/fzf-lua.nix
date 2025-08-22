{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    fd
  ];
  programs.nixvim.plugins.fzf-lua = {
    enable = false;
    settings.fzf_bin = lib.meta.getExe' pkgs.skim "sk";
    keymaps = {
      "<leader><leader>" = "files";
      "<leader>sg" = "live_grep_native";
    };
  };
}
