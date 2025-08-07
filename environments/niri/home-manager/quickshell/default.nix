{
  programs.quickshell = {
    enable = true;
    configs = ./.;
    systemd = {
      enable = true;
      target = "niri.service";
    };
  };
}
