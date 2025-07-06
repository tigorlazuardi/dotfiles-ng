{ config, pkgs, ... }:
let
  version = "3b19527ab936d6910484dcc20fb59bdb12322d8b";
  bufresizeRepo = pkgs.fetchFromGitHub {
    owner = "kwkarlwang";
    repo = "bufresize.nvim";
    rev = version;
    hash = "sha256-6jqlKe8Ekm+3dvlgFCpJnI0BZzWC3KDYoOb88/itH+g=";
  };
in
{
  programs.nixvim = {
    extraPlugins = [
      {
        plugin = pkgs.vimUtils.buildVimPlugin {
          inherit version;
          name = "bufresize.nvim";
          src = bufresizeRepo;
          doCheck = false;
          doInstallCheck = false;
        };
      }
    ];
    extraConfigLua = ''
      require("bufresize").setup {
        register = {
          keys = {},
        },
      }
    '';
  };
}
