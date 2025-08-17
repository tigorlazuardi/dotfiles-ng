{
  config,
  pkgs,
  ...
}:
let
in
{
  imports = [
    # swaync tinted theming requires wpaperd and wallust
    ./wpaperd.nix
    ./wallust.nix
  ];
  services.swaync.enable = true;
  xdg.configFile."wallust/templates/swaync.css".text = # css
    ''
      @import url("file://${config.xdg.dataHome}/wallpapers/gtk.css");

      * {
        all: unset;
        font-size: 14px;
        font-family: "Ubuntu Nerd Font";
      }

      trough highlight {
        background: @foreground;
      }

      scale {
        margin: 0 7px;
      }

      scale trough {
        margin: 0rem 1rem;
        min-height: 8px;
        min-width: 70px;
        border-radius: 12.6px;
      }

      trough slider {
        margin: -10px;
        border-radius: 12.6px;
        box-shadow: 0 0 2px alpha(@background, 0.8);
        transition: all 0.2s ease;
        background-color: @color1;
      }

      trough slider:hover {
        box-shadow:
          0 0 2px alpha(@background, 0.8),
          0 0 8px #89b4fa;
      }

      trough {
        background-color: @color1;
      }

      /* notifications */
      .notification-background {
        box-shadow:
          0 0 8px 0 alpha(@background, 0.8),
          inset 0 0 0 1px @color1;
        border-radius: 12.6px;
        margin: 18px;
        color: @foreground;
        padding: 0;
      }

      .notification-background .notification {
        padding: 7px;
        border-radius: 12.6px;
        background-color: alpha(@cursor, 0.6);
      }

      .notification-background .notification.critical {
        box-shadow: inset 0 0 7px 0 @color3;
      }

      .notification .notification-content {
        margin: 7px;
      }

      .notification .notification-content overlay {
        /* icons */
        margin: 4px;
      }

      .notification-content .summary {
        color: @foreground;
        font-weight: bold;
      }

      .notification-content .time {
        color: @foreground;
      }

      .notification-content .body {
        color: @foreground;
      }

      .notification > *:last-child > * {
        min-height: 3.4em;
      }

      .notification {
        transition: color 0.1s ease;
      }

      .notification-background .close-button {
        margin: 7px;
        padding: 2px;
        border-radius: 6.3px;
        color: #1e1e2e;
        background-color: @color3;
      }

      .notification-background .close-button:hover {
        background-color: @color6;
      }

      .notification-background .close-button:active {
        background-color: @color7;
      }

      .notification .notification-action {
        border-radius: 7px;
        color: @foreground;
        box-shadow: inset 0 0 0 1px @color8;
        margin: 4px;
        padding: 8px;
        font-size: 0.2rem; /* controls the button size not text size*/
      }

      .notification .notification-action {
        background-color: @color0;
      }

      .notification .notification-action:hover {
        background-color: @color1;
      }

      .notification .notification-action:active {
        background-color: @color6;
        color: @background;
      }

      .notification.critical progress {
        background-color: @color3;
      }

      .notification.low progress,
      .notification.normal progress {
        background-color: @color0;
      }

      .notification progress,
      .notification trough,
      .notification progressbar {
        border-radius: 12.6px;
        padding: 3px 0;
      }

      /* control center */
      .control-center {
        box-shadow:
          0 0 8px 0 alpha(@background, 0.8),
          inset 0 0 0 1px @foreground;
        border-radius: 12.6px;
        background-color: alpha(@background, 0.7);
        color: @foreground;
        padding: 14px;
      }

      .control-center .notification-background {
        border-radius: 7px;
        box-shadow: inset 0 0 0 1px @color10;
        margin: 4px 10px;
      }

      .control-center .notification-background .notification {
        border-radius: 7px;
        background-color: alpha({{cursor | darken(0.3)}}, 0.95);
        box-shadow:
          0 0 8px 0 alpha(@background, 0.8),
          inset 0 0 0 1px @foreground;
      }

      .control-center .widget-title > label {
        color: @foreground;
        font-size: 1.3em;
      }

      .control-center .widget-title button {
        border-radius: 7px;
        color: @foreground;
        background-color: @background;
        box-shadow: inset 0 0 0 1px #45475a;
        padding: 8px;
      }

      .control-center .widget-title button:hover {
        background-color: @cursor;
        color: @background;
      }

      .control-center .widget-title button:active {
        background-color: @color6;
        color: @background;
      }

      .control-center .notification-group {
        margin-top: 10px;
      }

      scrollbar slider {
        margin: -3px;
        opacity: 0.8;
      }

      scrollbar trough {
        margin: 2px 0;
      }

      /* dnd */
      .widget-dnd {
        margin-top: 5px;
        border-radius: 8px;
        font-size: 1.1rem;
      }

      .widget-dnd > switch {
        font-size: initial;
        border-radius: 8px;
        background: @color10;
        box-shadow: none;
      }

      .widget-dnd > switch:checked {
        background: @color4;
      }

      .widget-dnd > switch slider {
        background: @color6;
        border-radius: 8px;
      }

      /* mpris */
      .widget-mpris-player {
        background: #313244;
        border-radius: 12.6px;
        color: #cdd6f4;
      }

      .mpris-overlay {
        background-color: #313244;
        opacity: 0.9;
        padding: 15px 10px;
      }

      .widget-mpris-album-art {
        -gtk-icon-size: 100px;
        border-radius: 12.6px;
        margin: 0 10px;
      }

      .widget-mpris-title {
        font-size: 1.2rem;
        color: #cdd6f4;
      }

      .widget-mpris-subtitle {
        font-size: 1rem;
        color: #bac2de;
      }

      .widget-mpris button {
        border-radius: 12.6px;
        color: #cdd6f4;
        margin: 0 5px;
        padding: 2px;
      }

      .widget-mpris button image {
        -gtk-icon-size: 1.8rem;
      }

      .widget-mpris button:hover {
        background-color: #313244;
      }

      .widget-mpris button:active {
        background-color: #45475a;
      }

      .widget-mpris button:disabled {
        opacity: 0.5;
      }

      .widget-menubar > box > .menu-button-bar > button > label {
        font-size: 3rem;
        padding: 0.5rem 2rem;
      }

      .widget-menubar > box > .menu-button-bar > :last-child {
        color: #f38ba8;
      }

      .power-buttons button:hover,
      .powermode-buttons button:hover,
      .screenshot-buttons button:hover {
        background: #313244;
      }

      .control-center .widget-label > label {
        color: #cdd6f4;
        font-size: 2rem;
      }

      .widget-buttons-grid {
        padding-top: 1rem;
      }

      .widget-buttons-grid > flowbox > flowboxchild > button label {
        font-size: 2.5rem;
      }

      .widget-volume {
        padding: 1rem 0;
      }

      .widget-volume label {
        color: #74c7ec;
        padding: 0 1rem;
      }

      .widget-volume trough highlight {
        background: #74c7ec;
      }

      .widget-backlight trough highlight {
        background: #f9e2af;
      }

      .widget-backlight label {
        font-size: 1.5rem;
        color: #f9e2af;
      }

      .widget-backlight .KB {
        padding-bottom: 1rem;
      }

      .image {
        padding-right: 0.5rem;
      }
    '';
  programs.wallust = {
    settings.templates.swaync = {
      src = "swaync.css";
      dst = "${config.xdg.configHome}/swaync/style.css";
    };
    postRun = "swaync-client --reload-css";
  };
  systemd.user.services.swaync = {
    Unit.After = [ "wpaperd.service" ];
    Unit.ExecPreStart = pkgs.writeShellScript "swaync-pre-start" ''
      until [ -f "${config.xdg.configHome}/swaync/style.css" ]; do
        sleep 0.1;
      done
    '';
  };
  stylix.targets.swaync.enable = false; # We will use Rose-Pine's swaync official styling.
}
