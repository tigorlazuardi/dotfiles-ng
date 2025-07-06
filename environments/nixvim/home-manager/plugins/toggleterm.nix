{ pkgs, ... }:
{
  programs.nixvim = {
    extraPackages = with pkgs; [
      lazygit
    ];
    # extraConfigLua = ''
    #   do
    #     local Terminal = require("toggleterm.terminal").Terminal
    #     local lazygit = Terminal:new {
    #       cmd = "lazygit",
    #       hidden = true,
    #       direction = "float",
    #       on_open = function(term) vim.cmd "startinsert!" end,
    #     }
    #     vim.keymap.set(
    #       "n",
    #       "<leader>z",
    #       function() lazygit:toggle() end,
    #       { desc = "Toggle Lazygit" }
    #     )
    #   end
    # '';
    plugins.toggleterm = {
      enable = false;
      settings = {
        size.__raw = ''
          function(term)
            if term.direction == "horizontal" then
              return vim.o.lines * 0.3
            end
            return vim.o.columns * 0.3
          end
        '';
        open_mapping.__raw = ''"<F5>"'';
      };
    };
  };
}
