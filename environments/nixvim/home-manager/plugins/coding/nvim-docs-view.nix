{ pkgs, ... }:
{
  programs.nixvim = {
    extraPlugins = [
      {
        plugin = pkgs.vimUtils.buildVimPlugin {
          pname = "nvim-docs-view";
          version = "1b97f8f";
          src = pkgs.fetchFromGitHub {
            owner = "amrbashir";
            repo = "nvim-docs-view";
            rev = "1b97f8f954d74c46061bf289b6cea9232484c12c";
            hash = "sha256-b5aH8Tj+tMk0BjNCgdeCEeR26oQ9NCobj98P7IDgIPY=";
          };
          doCheck = false;
          doInstallCheck = false;
        };
      }
    ];
    extraConfigLua = ''
      require("lz.n").load {
        "nvim-docs-view",
        keys = {
          {
            "<a-k>",
            "<cmd>DocsViewUpdate<cr>",
            desc = "Hover Documentation to the Side",
          },
        },
        cmd = { "DocsViewToggle", "DocsViewUpdate" },
        after = function()
          require("docs-view").setup {
            position = "right",
            width = 60,
            update_mode = "manual",
          }
        end,
      }
    '';
  };

}
