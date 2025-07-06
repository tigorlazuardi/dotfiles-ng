{
  pkgs,
  inputs,
  lib,
  ...
}:
{
  imports = [
    ./coding

    ./arrow.nix
    ./blink.nix
    ./bufresize.nix
    # ./dadbod.nix # dadbod breaks all the time, so we disable it for now
    ./flash.nix
    ./fugitive.nix
    ./gitsigns.nix
    ./grug-far.nix
    ./lualine.nix
    ./mini.nix
    ./neo-tree.nix
    ./noice.nix
    ./persistence.nix
    ./protobuf.nix
    ./snacks.nix
    ./telescope.nix
    ./tiny-inline-diagnostics.nix
    ./toggleterm.nix
    ./treesitter.nix
    ./trouble.nix
    ./ufo.nix
    ./which-key.nix
    ./yanky.nix
  ];

  programs.nixvim = {
    extraPlugins = [
      (pkgs.vimUtils.buildVimPlugin {
        pname = "lzn-auto-require";
        src = inputs.lzn-auto-require-nvim;
        version = inputs.lzn-auto-require-nvim.shortRev;
        doCheck = false;
        doInstallCheck = false;
      })
    ];
    extraConfigLuaPost =
      lib.mkAfter
        # lua
        ''
          require("lzn-auto-require").enable()
        '';
    # Must be enabled for lazyLoading settings to work
    plugins.lz-n.enable = true;
  };
}
