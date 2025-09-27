{
  programs.niri.extraConfigPost = # kdl
    ''
      window-rule {
        match app-id="neovide"
        open-maximized true
      }
    '';
}
