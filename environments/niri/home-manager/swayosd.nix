{ config, ... }:
{
  imports = [
    ../../window-manager/home-manager/swayosd.nix
  ];

  programs.niri.settings.binds = with config.lib.niri.actions; {
    "XF86AudioRaisevolume" = {
      allow-when-locked = true;
      action = spawn "swaysosd-client" "--output-volume" "raise";
    };
    "XF86AudioLowervolume" = {
      allow-when-locked = true;
      action = spawn "swaysosd-client" "--output-volume" "lower";
    };
    "XF86AudioMute" = {
      allow-when-locked = true;
      action = spawn "swaysosd-client" "--output-volume" "mute-toggle";
    };
    "XF86AudioMicMute" = {
      allow-when-locked = true;
      action = spawn "swayosd-client" "--input-volume" "mute-toggle";
    };
    "XF86MonBrightnessUp" = {
      allow-when-locked = true;
      action = spawn "swayosd-client" "--brightness" "raise";
    };
    "XF86MonBrightnessDown" = {
      allow-when-locked = true;
      action = spawn "swayosd-client" "--brightness" "lower";
    };
  };
}
