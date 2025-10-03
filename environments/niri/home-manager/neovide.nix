{
  programs.niri.settings.window-rules = [
    {
      matches = [ { app-id = "neovide"; } ];
      open-maximized = true;
      shadow = {
        enable = true;
        color = "#00000033";
        draw-behind-window = true;
        softness = 60;
        spread = 30;
        offset = {
          x = 0;
          y = 0;
        };
      };
    }
  ];
}
