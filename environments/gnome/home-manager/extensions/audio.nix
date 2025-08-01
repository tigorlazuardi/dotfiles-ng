{ pkgs, ... }:
{
  home.packages = with pkgs.gnomeExtensions; [
    quick-settings-audio-panel
    quick-settings-audio-devices-renamer
    quick-settings-audio-devices-hider
  ];
  dconf.settings = {
    "org/gnome/shell" = {
      enabled-extensions = with pkgs.gnomeExtensions; [
        quick-settings-audio-panel.extensionUuid
        quick-settings-audio-devices-renamer.extensionUuid
        quick-settings-audio-devices-hider.extensionUuid
      ];
    };
  };
}
