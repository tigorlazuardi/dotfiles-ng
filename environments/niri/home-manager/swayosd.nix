{
  imports = [
    ../../window-manager/home-manager/swayosd.nix
  ];

  programs.niri.settings.binds = {
    "XF86AudioRaisevolume" = {
      _props.repeat = true;
      spawn = "swayosd-client --output-volume raise";
    };
    "XF86AudioLowervolume" = {
      _props.repeat = true;
      spawn = "swayosd-client --output-volume lower";
    };
    "XF86AudioMute" = {
      _props.repeat = false;
      spawn = "swayosd-client --output-volume mute-toggle";
    };
    "XF86AudioMicMute" = {
      _props.repeat = false;
      spawn = "swayosd-client --input-volume mute-toggle";
    };
    "XF86MonBrightnessUp" = {
      _props.repeat = true;
      spawn = "swayosd-client --brightness raise";
    };
    "XF86MonBrightnessDown" = {
      _props.repeat = true;
      spawn = "swayosd-client --brightness lower";
    };
  };
}
