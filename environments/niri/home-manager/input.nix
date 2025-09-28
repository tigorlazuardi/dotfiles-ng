{
  programs.niri.settings.input = {
    keyboard.xkb.layout = "us";
    focus-follows-mouse = {
      enable = true;
      max-scroll-amount = "10%"; # Only focus on a window if the window under cursor will not cause scrolling the workspace more than this amount.
    };
  };
}
