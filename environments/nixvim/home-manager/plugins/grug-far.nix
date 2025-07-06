{ pkgs, ... }:
{
  programs.nixvim.plugins.grug-far = {
    enable = true;
    package = pkgs.vimPlugins.grug-far-nvim;
    lazyLoad.settings = {
      cmd = [ "GrugFar" ];
      keys = [
        {
          __unkeyed-1 = "<leader>sr";
          __unkeyed-2.__raw = ''
            function()
              local grug = require("grug-far")
              local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
              grug.open({
                transient = true,
                prefills = {
                  filesFilter = ext and ext ~= "" and "*." .. ext or nil,
                },
              })
            end
          '';
          mode = [
            "n"
            "v"
          ];
          desc = "Search and Replace";
        }
      ];
    };
  };
}
