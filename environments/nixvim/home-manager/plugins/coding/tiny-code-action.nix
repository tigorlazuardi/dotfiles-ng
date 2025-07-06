{ pkgs, inputs, ... }:
{
  programs.nixvim = {
    extraPlugins = with pkgs; [
      {
        plugin = vimUtils.buildVimPlugin {
          pname = "tiny-code-action.nvim";
          src = inputs.tiny-code-action;
          version = inputs.tiny-code-action.shortRev;
          doCheck = false;
          doInstallCheck = false;
        };
      }
    ];
    extraConfigLua = ''
      require("lz.n").load {
        "tiny-code-action.nvim",
        event = "LspAttach",
        after = function()
          require("tiny-code-action").setup {}
          vim.keymap.set(
            "n",
            "<leader>ca",
            function() require("tiny-code-action").code_action() end,
            { noremap = true, silent = true, desc = "Code Action" }
          )
        end,
      }
    '';
  };
}
