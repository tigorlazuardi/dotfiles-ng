{
  programs.wezterm.settings = {
    enable_wayland = true;
    hide_tab_bar_if_only_one_tab = true;
    window_decorations = "INTEGRATED_BUTTONS | TITLE | RESIZE";
    integrated_title_buttons = [
      "Hide"
      "Maximize"
      "Close"
    ];
  };
}
