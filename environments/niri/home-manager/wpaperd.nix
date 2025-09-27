{
  imports = [ ../../window-manager/home-manager/wpaperd.nix ];

  programs.niri.settings.binds = {
    "Mod+u" = {
      _props.repeat = false;
      spawn = [
        "wpaperctl"
        "next"
      ];
    };
    "Mod+y" = {
      _props.repeat = false;
      spawn = [
        "wpaperctl"
        "previous"
      ];
    };
  };
}
