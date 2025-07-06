{ inputs, pkgs, ... }:
{
  programs.nixvim = {
    extraPlugins = with pkgs; [
      {
        plugin = vimUtils.buildVimPlugin {
          pname = "tiny-inline-diagnostic.nvim";
          version = inputs.tiny-inline-diagnostic-nvim.shortRev;
          src = inputs.tiny-inline-diagnostic-nvim;
          doCheck = false;
          doInstallCheck = false;
        };
        optional = true;
      }
    ];
    extraConfigLua = # lua
      ''
        require("lz.n").load {
          "tiny-inline-diagnostic.nvim",
          event = { "DeferredUIEnter" },
          after = function()
            require("tiny-inline-diagnostic").setup {
              preset = "powerline",
              options = {
                show_source = true,
                throttle = 0,
                multilines = {
                  enabled = true,
                  always_show = true,
                },
                multiple_diag_under_cursor = true,
                enable_on_insert = true,
              },
            }
            vim.diagnostic.config { virtual_text = false }
          end,
        }
      '';
  };
}
