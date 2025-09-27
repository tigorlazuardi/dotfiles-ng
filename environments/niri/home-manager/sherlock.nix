{
  imports = [
    ../../window-manager/home-manager/sherlock
  ];

  # TODO: create a script to search window by title and focus

  programs.niri.settings.binds = {
    "Mod+BackSpace" = {
      _props.repeat = false;
      spawn = "sherlock --sub-menu pm";
    };
    "Mod+a" = {
      _props.repeat = false;
      spawn = "sherlock-select-audio";
    };
    "Mod+c" = {
      _props.repeat = false;
      spawn = "sherlock-clipboard";
    };
    "Mod+s" = {
      _props.repeat = false;
      spawn = "sherlock-systemd-user";
    };
    "Mod+z" = {
      _props.repeat = false;
      spawn = "sherlock-zoxide";
    };
    "Mod+n" = {
      _props.repeat = false;
      spawn = "sherlock-zoxide neovide";
    };
    "Mod+m" = {
      _props.repeat = false;
      spawn = "sherlock-zoxide nemo";
    };
    "Mod+d" = {
      _props.repeat = false;
      spawn = "sherlock";
    };
  };
}
