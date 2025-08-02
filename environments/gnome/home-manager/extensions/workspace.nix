{ pkgs, ... }:
{
  home.packages = with pkgs.gnomeExtensions; [
    go-to-last-workspace
  ];

  dconf.settings = {
    "org/gnome/shell".enabled-extensions = with pkgs.gnomeExtensions; [
      go-to-last-workspace.extensionUuid
    ];
    # "org/gnome/shell/extensions/azwallpaper".slideshow-directory =
    #   "${config.home.homeDirectory}/sync/Redmage/Windows";
  };
}
