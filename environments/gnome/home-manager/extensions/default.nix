{ pkgs, ... }:
{
  imports = [
    ./wallpaper-slideshow.nix
    ./bangs-search.nix
  ];
  home.packages = with pkgs.gnomeExtensions; [
    appindicator
    wsp-windows-search-provider
    wireguard-vpn-extension
    user-themes
    removable-drive-menu
    extension-list
    # just-perfection
    # system-monitor

    pkgs.dconf-editor
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
          extension-list.extensionUuid
          # just-perfection.extensionUuid
          # system-monitor.extensionUuid
        ];
        favorite-apps = [
          "org.gnome.Console.desktop"
        ];
      };
    };
  };
}
