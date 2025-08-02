{ config, lib, ... }:
# Access stdlib
with lib;
let
  # Access nixvim lib
  inherit (config.lib.nixvim) lua-types lua;
in
{
  imports = [
    ./keymaps.nix
    ./ui.nix
  ];
  options.programs.wezterm.settings = mkOption {
    type = lua-types.tableOf lua-types.anything;
    default = { };
  };

  config = {
    programs.wezterm = {
      enable = true;
      extraConfig =
        let
          toLuaObject = lua.toLua' {
            multiline = true;
            indent = "    ";
          };
        in
        # lua
        ''return${" "}${toLuaObject config.programs.wezterm.settings}'';
    };
  };
}
