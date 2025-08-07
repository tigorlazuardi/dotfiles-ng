{ pkgs, ... }:
{
  programs.nixvim.extraPlugins = [
    (pkgs.vimUtils.buildVimPlugin (rec {
      pname = "submode";
      version = "6.4.2";
      src = pkgs.fetchFromGitHub {
        owner = "pogyomo";
        repo = "submode.nvim";
        rev = "v${version}";
        hash = "sha256-RYf/gyz1Mo38rl/UjjR9vUBfOsxwS3TBDb/1hx7a3Tw=";
      };
      doCheck = false;
      doInstallCheck = false;
    }))
  ];

  programs.nixvim.plugins.smart-splits.enable = true;

  programs.nixvim.extraConfigLua = ''
    do
      local submode = require "submode"
      local submode = require "submode"
      submode.create("WinResize", {
        mode = "n",
        enter = "<C-w>r",
        leave = { "<Esc>", "q", "<C-c>", "<cr>" },
        hook = {
          on_enter = function()
            vim.notify "WinResize mode: Use { h, j, k, l } or { <Left>, <Down>, <Up>, <Right> } to resize the window"
          end,
          on_leave = function() vim.notify "Exited WinResize mode" end,
        },
        default = function(register)
          -- stylua: ignore start
          register('h', require('smart-splits').resize_left, { desc = 'Resize left' })
          register('j', require('smart-splits').resize_down, { desc = 'Resize down' })
          register('k', require('smart-splits').resize_up, { desc = 'Resize up' })
          register('l', require('smart-splits').resize_right, { desc = 'Resize right' })
          register('<Left>', require('smart-splits').resize_left, { desc = 'Resize left' })
          register('<Down>', require('smart-splits').resize_down, { desc = 'Resize down' })
          register('<Up>', require('smart-splits').resize_up, { desc = 'Resize up' })
          register('<Right>', require('smart-splits').resize_right, { desc = 'Resize right' })
          -- stylua: ignore end
        end,
      })
    end
  '';
}
