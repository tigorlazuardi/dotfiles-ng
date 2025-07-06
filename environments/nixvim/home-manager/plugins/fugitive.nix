{ pkgs, ... }:
{
  programs.nixvim = {
    extraPackages = with pkgs; [ git ];
    extraPlugins = [
      {
        plugin = pkgs.vimPlugins.vim-fugitive;
        optional = true;
      }
    ];

    extraConfigLua = ''
      require("lz.n").load {
        "vim-fugitive",
        event = "DeferredUIEnter",
      }
    '';
  };
}
