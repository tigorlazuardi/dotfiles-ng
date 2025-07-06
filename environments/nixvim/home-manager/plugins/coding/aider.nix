{ pkgs, inputs, ... }:
{
  programs.nixvim = {
    extraPlugins = [
      {
        plugin = pkgs.vimUtils.buildVimPlugin {
          pname = "nvim-aider";
          version = inputs.nvim-aider.shortRev;
          src = inputs.nvim-aider;
          doCheck = false;
          doInstallCheck = false;
        };
        optional = true;
      }
    ];
    extraConfigLua = ''
      require("lz.n").load {
        "nvim-aider",
        cmd = {
          "Aider",
        },
        keys = {
          { "<localleader>a", "<cmd>Aider toggle<cr>", desc = "Toggle Aider" },
          {
            "<localleader>A",
            "<cmd>Aider send<cr>",
            desc = "Send to Aider",
            mode = { "n", "v" },
          },
          {
            "<localleader>s",
            "<cmd>Aider add<cr>",
            desc = "Add File to Aider",
          },
          {
            "<localleader>S",
            "<cmd>Aider drop<cr>",
            desc = "Drop File from Aider",
          },
          {
            "<localleader>b",
            "<cmd>Aider buffer<cr>",
            desc = "Send Buffer To Aider",
          },
          {
            "<localleader>r",
            "<cmd>Aider add readonly<cr>",
            desc = "Add File as Read-Only",
          },
        },
        after = function()
          require("nvim_aider").setup {
            args = {
              "--no-auto-commits",
              "--pretty",
              "--stream",
              "--no-show-release-notes",
            },
            auto_reload = true,
            win = {
              position = "right",
            },
          }
        end,
      }
    '';
  };
}
