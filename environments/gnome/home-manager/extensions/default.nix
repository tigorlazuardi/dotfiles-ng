{ pkgs, ... }:
{
  imports = [
    ./audio.nix
    ./clipboard.nix
    ./dash-to-dock.nix
    ./notification.nix
    ./tiling-shell.nix
    ./wallpaper-slideshow.nix
    ./workspace.nix
  ];
  home.packages = with pkgs.gnomeExtensions; [
    appindicator
    wsp-windows-search-provider
    wireguard-vpn-extension
    user-themes
    removable-drive-menu
    system-monitor
    gsconnect
    grand-theft-focus
    keep-awake
    hibernate-status-button
    tweaks-in-system-menu
    weeks-start-on-monday-again
    do-not-disturb-while-screen-sharing-or-recording

    # Just Perfection GNOME Shell Extension must not be used with Stylix enabled.
    # It causes system freeze on login.
    #
    # just-perfection

    # Tools to help debug GNOME Shell extension configurations.
    pkgs.dconf-editor
    pkgs.refine
    pkgs.gnome-tweaks
  ];
  dconf = {
    enable = true;
    settings = {
      "org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = with pkgs.gnomeExtensions; [
          user-themes.extensionUuid
          appindicator.extensionUuid
          wsp-windows-search-provider.extensionUuid
          wireguard-vpn-extension.extensionUuid
          removable-drive-menu.extensionUuid
          system-monitor.extensionUuid
          gsconnect.extensionUuid
          grand-theft-focus.extensionUuid
          keep-awake.extensionUuid
          quick-settings-audio-panel.extensionUuid
          hibernate-status-button.extensionUuid
          tweaks-in-system-menu.extensionUuid
          weeks-start-on-monday-again.extensionUuid
          do-not-disturb-while-screen-sharing-or-recording.extensionUuid
        ];
      };
    };
  };
}
