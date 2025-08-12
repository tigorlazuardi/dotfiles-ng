{
  pkgs,
  lib,
  ...
}:
{

  home.packages = with pkgs; [
    nemo-with-extensions
    file-roller
  ];
  dconf.settings = {
    "org/gnome/shell".favorite-apps = [
      "nemo.desktop"
    ];
    "org/nemo/preferences" = {
      show-hidden-files = true;
      show-image-thumbnails = "always";
      thumbnail-limit = lib.hm.gvariant.mkUint64 (100 * 1024 * 1024); # 100 MiB
    };
    "org/nemo/preferences/menu-config" = {
      # Since we are using nemo not in Cinnamon desktop, open in terminal will not work.
      selection-menu-open-in-terminal = false;
      background-menu-open-in-terminal = false;
    };
  };
}
