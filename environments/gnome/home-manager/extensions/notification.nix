{ pkgs, ... }:
{
  home.packages = with pkgs.gnomeExtensions; [
    notification-timeout
    notification-counter
  ];
  dconf.settings = {
    "org/gnome/shell" = {
      enabled-extensions = with pkgs.gnomeExtensions; [
        notification-timeout.extensionUuid
        notification-counter.extensionUuid
      ];
    };
    "org/gnome/shell/extensions/notification-timeout" = {
      timeout = 5000; # 5 seconds
      # Disable notification always open when idle.
      #
      # This is annoying when you are watching a video and the notification
      # stays open.
      ignore-idle = true;
      # Treat critical notifications as normal.
      #
      # Critical notifications are always stay open.
      always-normal = true;
    };
    # "org/gnome/shell/extensions/clipboard-indicator" = {
    #   move-item-first = true;
    #   strip-text = true;
    #   history-size = 100;
    # };
  };
}
