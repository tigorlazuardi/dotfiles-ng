{
  programs.niri.settings.input = {
    keyboard.xkb.layout = "us";
    # Focus follow mouse, but only if the view in current monitor will not be scrolled. Useful for multi-monitor setups.
    focus-follows-mouse._props.max-scroll-amount = "10%";
  };
}
