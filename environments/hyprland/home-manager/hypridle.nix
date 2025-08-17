{
  imports = [
    ../../window-manager/home-manager/hypridle.nix
  ];
  services.hypridle.settings = {
    general.after_sleep_cmd = "hyprctl dispatch dpms on";
    listener = [
      {
        timeout = (15 * 60) + 30; # 15 minutes + 30 seconds
        on-timeout = "hyprctl dispatch dpms off"; # Turn off the screen
        on-resume = "hyprctl dispatch dpms on && brightnessctl -r";
      }
    ];
  };
}
