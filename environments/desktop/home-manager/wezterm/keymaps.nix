{
  programs.wezterm.settings = {
    leader = {
      key = "a";
      mods = "CTRL";
      timeout_milliseconds = 10000; # 10 secs
    };
    keys = [
      {
        key = "a";
        mods = "LEADER|CTRL";
        action.__raw = ''wezterm.action.SendKey { key = "a", mods = "CTRL" }'';
      }
      {
        key = "Enter";
        mods = "LEADER";
        action.__raw = ''wezterm.action.SplitHorizontal { domain = "CurrentPaneDomain" }'';
      }
    ];
  };
}
