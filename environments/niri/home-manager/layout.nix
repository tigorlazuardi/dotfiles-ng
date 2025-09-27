{
  programs.niri.setting.layout = {
    center-focused-column = "always";

    preset-column-widths._children = [
      { proportion = 0.1; } # Left screen 10%
      { proportion = 0.8; } # Center screen 80%
      { proportion = 0.1; } # Right screen 10%
    ];
  };
}
