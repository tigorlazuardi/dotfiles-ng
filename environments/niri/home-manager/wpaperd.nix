{
  imports = [ ../../window-manager/home-manager/wpaperd.nix ];

  programs.niri.settings.binds = {
    "Mod+u".action.spawn = [
      "wpaperctl"
      "next"
    ];
    "Mod+y".action.spawn = [
      "wpaperctl"
      "previous"
    ];
  };
}
