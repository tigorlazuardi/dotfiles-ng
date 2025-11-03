{ config, ... }:
{
  imports = [
    ../../desktop/home-manager/optional/flameshot.nix
  ];
  programs.niri.settings = {
    window-rules = [
      {
        matches = [ { title = "^Capture Launcher$"; } ];
        open-floating = true;
      }
    ];
    binds = with config.lib.niri.actions; {
      "Print" = {
        action = spawn "flameshot" "gui";
        hotkey-overlay.title = "Take Screenshot";
      };
      "Shift+Print" = {
        action = spawn "flameshot" "launcher";
        hotkey-overlay.title = "Open Screenshot Launcher";
      };
      "Alt+Print" = {
        action = spawn "claude-screenshot";
        hotkey-overlay.title = "Take Claude Screenshot";
      };
    };
  };
}
