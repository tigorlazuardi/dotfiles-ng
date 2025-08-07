{ pkgs, lib, ... }:
let
  # Run bash command:
  #
  # dconf read /org/gnome/shell/extensions/tilingshell/layouts-json | td -d "'" | json2nix
  #
  # to generate the nix value from json string. Note that json2nix is located from utils.nix, not from web.
  layouts = [
    {
      # Big Center, 2 Small Left, 2 Small Right
      id = "Layout 1";
      tiles = [
        {
          groups = [
            1
            2
          ];
          height = 0.5;
          width = 0.22;
          x = 0;
          y = 0;
        }
        {
          groups = [
            1
            2
          ];
          height = 0.5;
          width = 0.22;
          x = 0;
          y = 0.5;
        }
        {
          groups = [
            2
            3
          ];
          height = 1;
          width = 0.56;
          x = 0.22;
          y = 0;
        }
        {
          groups = [
            3
            4
          ];
          height = 0.5;
          width = 0.22;
          x = 0.78;
          y = 0;
        }
        {
          groups = [
            3
            4
          ];
          height = 0.5;
          width = 0.22;
          x = 0.78;
          y = 0.5;
        }
      ];
    }
    {
      # Big Center, Small Left and Right
      id = "Layout 2";
      tiles = [
        {
          groups = [ 1 ];
          height = 1;
          width = 0.22;
          x = 0;
          y = 0;
        }
        {
          groups = [
            1
            2
          ];
          height = 1;
          width = 0.56;
          x = 0.22;
          y = 0;
        }
        {
          groups = [ 2 ];
          height = 1;
          width = 0.22;
          x = 0.78;
          y = 0;
        }
      ];
    }
    {
      id = "Big Right, Small Left";
      tiles = [
        {
          groups = [ 1 ];
          height = 1;
          width = 0.4;
          x = 0;
          y = 0;
        }
        {
          groups = [ 1 ];
          height = 1;
          width = 0.6;
          x = 0.4;
          y = 0;
        }
      ];
    }
    {
      id = "Big Left, Small Right";
      tiles = [
        {
          groups = [ 1 ];
          height = 1;
          width = 0.6;
          x = 0;
          y = 0;
        }
        {
          groups = [ 1 ];
          height = 1;
          width = 0.4;
          x = 0.6;
          y = 0;
        }
      ];
    }
    {
      # Big Left, 2 Right
      id = "Big Left, 2 Right";
      tiles = [
        {
          groups = [ 1 ];
          height = 1;
          width = 0.6;
          x = 0;
          y = 0;
        }
        {
          groups = [
            1
            2
          ];
          height = 0.5;
          width = 0.4;
          x = 0.6;
          y = 0;
        }
        {
          groups = [
            1
            2
          ];
          height = 0.5;
          width = 0.4;
          x = 0.6;
          y = 0.5;
        }
      ];
    }
  ];
in
{

  home.packages = with pkgs.gnomeExtensions; [
    tiling-shell
  ];
  dconf.settings = {
    "org/gnome/shell" = {
      enabled-extensions = with pkgs.gnomeExtensions; [
        tiling-shell.extensionUuid
      ];
    };
    "org/gnome/desktop/wm/keybindings" = {
      minimize = [ ];
    };
    "org/gnome/settings-daemon/plugins/media-keys".screensaver = [ ]; # This is Lock Screen shortcut;
    "org/gnome/shell/extensions/tilingshell" = {
      # enable-autotiling = true;
      inner-gaps = lib.hm.gvariant.mkUint32 2; # 2px inner gaps
      outer-gaps = lib.hm.gvariant.mkUint32 0; # 2px outer gaps
      focus-window-up = [ "<Super>k" ];
      focus-window-down = [ "<Super>j" ];
      focus-window-left = [ "<Super>h" ];
      focus-window-right = [ "<Super>l" ];
      move-window-up = [ "<Control><Super>k" ];
      move-window-down = [ "<Control><Super>j" ];
      move-window-left = [ "<Control><Super>h" ];
      move-window-right = [ "<Control><Super>l" ];
      span-window-up = [ "<Shift><Super>k" ];
      span-window-down = [ "<Shift><Super>j" ];
      span-window-left = [ "<Shift><Super>h" ];
      span-window-right = [ "<Shift><Super>l" ];
      layouts-json = builtins.toJSON layouts;
    };
  };
}
