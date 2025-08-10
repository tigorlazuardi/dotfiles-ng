{
  config,
  ...
}:
{
  services.hypridle = {
    enable = config.wayland.windowManager.hyprland.enable;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };
      listener = [
        {
          timeout = 15 * 60; # 15 minutes
          on-timeout = "brightnessctl -s set 10"; # Dim the screen after 15 minutes of inactivity
          on-resume = "brightnessctl -r";
        }
        {
          timeout = (15 * 60) + 30; # 15 minutes + 30 seconds
          on-timeout = "hyprctl dispatch dpms off"; # Turn off the screen
          on-resume = "hyprctl dispatch dpms on && brightnessctl -r";
        }
        {
          timeout = 16 * 60; # 16 minutes
          on-timeout = "loginctl lock-session"; # Lock the session after 16 minutes
        }
        {
          timeout = 20 * 60; # 20 minutes
          on-timeout = "systemctl suspend-then-hibernate"; # Sleep after 20 minutes, then hibernate after.
        }
      ];
    };
  };
}
