{
  programs.niri.settings.layout = {
    shadow = {
      enable = true;
    };
    preset-column-widths = [
      # When action to rotate column widths is triggered, the widths will be set to the next in this list.
      { proportion = 1. / 3.; } # 1/3 of the screen
      { proportion = 1. / 2.; } # 1/2 of the screen
      { proportion = 2. / 3.; } # 2/3 of the screen
    ];
  };
}
