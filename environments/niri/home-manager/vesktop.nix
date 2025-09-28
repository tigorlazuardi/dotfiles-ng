{ config, ... }:
let
  workspace = config.programs.niri.settings.workspaces."10-chat".name;
in
{
  imports = [ ./workspace_chat.nix ];

  programs.niri.settings.window-rules = [
    {
      matches = [ { app-id = "vesktop"; } ];
      open-on-workspace = workspace;
      open-maximized = true;
      block-out-from = "screencast"; # block from screen share but allow screenshots
    }
  ];
}
