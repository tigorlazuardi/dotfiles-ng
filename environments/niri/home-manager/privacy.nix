{
  programs.niri.extraConfigPost = # kdl
    ''
      window-rule {
        match app-id="Slack"
        match app-id="wasistlos"
        match app-id="vesktop"

        block-out-from "screencast" // block from screen share but allow screenshots
      }
    '';
}
