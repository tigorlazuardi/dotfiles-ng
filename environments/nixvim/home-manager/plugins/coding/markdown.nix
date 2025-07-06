{ pkgs, ... }:
{
  programs.nixvim = {
    extraPackages = with pkgs; [ prettierd ];
    extraConfigLua = # lua
      ''
        require("lz.n").load {
          "markdown-preview.nvim",
          ft = "markdown",
        }
      '';
    plugins = {
      conform-nvim.settings.formatters_by_ft.markdown = [
        "injected"
        "prettierd"
      ];
      markdown-preview = {
        enable = true;
        autoLoad = false;
      };
      render-markdown = {
        enable = true;
        lazyLoad.settings.ft = [ "markdown" ];
      };
    };
  };
}
