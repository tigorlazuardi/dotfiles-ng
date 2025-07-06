{ pkgs, ... }:
{
  programs.nixvim = {
    extraPackages = with pkgs; [ shfmt ];
    plugins.conform-nvim.settings.formatters_by_ft = {
      zsh = [ "shfmt" ];
      bash = [ "shfmt" ];
      sh = [ "shfmt" ];
    };
  };
}
