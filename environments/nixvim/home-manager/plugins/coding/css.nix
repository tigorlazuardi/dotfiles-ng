{ pkgs, ... }:
{
  programs.nixvim = {
    extraPlugins = [
      {
        plugin = pkgs.vimUtils.buildVimPlugin rec {
          pname = "nvim-highlight-colors";
          version = "a770df5fbd98abbb0fc1a95d9a3f2bb1e51e3e2c";
          src = pkgs.fetchFromGitHub {
            owner = "brenoprata10";
            repo = "nvim-highlight-colors";
            rev = version;
            hash = "sha256-aZmxPwfoDNLpQX6A+X0vcAsGNkn1X/7gJs41yJekwt8=";
          };
          doCheck = false;
          doInstallCheck = false;
        };
        optional = true;
      }
    ];
    extraConfigLua = ''
      require("lz.n").load {
        "nvim-highlight-colors",
        ft = { "css", "scss", "sass", "less", "typescriptreact", "javascriptreact" },
        after = function()
          vim.opt.termguicolors = true

          require("nvim-highlight-colors").setup {}
        end,
      }
    '';
    plugins.lsp.servers.cssls.enable = true;
    plugins.conform-nvim.settings.formatters_by_ft.css = [ "prettierd" ];
  };
}
