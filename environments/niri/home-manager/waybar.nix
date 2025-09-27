{ lib, ... }:
{
  imports = [
    ../../window-manager/home-manager/waybar.nix
  ];

  programs.waybar.settings.main = {
    modules-left = lib.mkAfter [ "niri/workspaces" ];
  };

  xdg.configFile."wallust/templates/waybar.css".text = # css
    ''
      * {
        font-family: "JetBrainsMono Nerd Font";
      }

      #workspaces {
        background-color: alpha(@color0, 0.5);
        color: @foreground;
        margin-right: 0.5rem;
        margin-left: 0.5rem;
        margin-top: 0.5rem;
        border-radius: 1rem;
        padding-top: 1rem;
        padding-bottom: 1rem;
        border-style: solid;
        border-color: @cursor;
        border-width: 2px;
      }

      #workspaces button {
        padding-top: 0.25rem;
        padding-bottom: 0.25rem;
        color: @foreground;
      }

      #workspaces button.visible {
        border-bottom-color: @cursor;
        border-bottom-width: 0.25rem;
        border-radius: 0.25rem;
      }

      #workspaces button {
        padding-top: 0.5rem;
      }

      #workspaces button:hover {
        background-color: @color1;
        color: @foreground;
        border-radius: 0;
      }

      #window {
        padding-bottom: 2rem;
        padding-top: 2rem;
        color: @foreground;
      }
    '';
}
