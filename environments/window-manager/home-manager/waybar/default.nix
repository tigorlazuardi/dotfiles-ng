{
  config,
  pkgs,
  ...
}:
{
  imports = [
    # Waybar has dependency with swaync
    ../swaync.nix
    ../wallust.nix
    ../wpaperd.nix
  ];
  programs.waybar.enable = true;
  programs.waybar.settings = {
    backlight = {
      device = "intel_backlight";
      format = "{percent}% {icon}";
      format-icons = [
        ""
        ""
      ];
    };
    battery = {
      format = "{icon}";
      format-alt = "{time} {icon}";
      format-charging = "󱊦";
      format-full = "󰁹";
      format-icons = [
        "󰁺"
        "󰁻"
        "󰁼"
        "󰁽"
        "󰁾"
        "󰁿"
        "󰂀"
        "󰂁"
        "󰂂"
        "󰁹"
      ];
      format-plugged = "󰚥";
      states = {
        critical = 15;
        warning = 30;
      };
    };
    "clock#hour" = {
      format = "{:%H}";
      tooltip-format = "{:%A, %B %d, %Y (%R)}";
    };
    "clock#icon" = {
      format = " 󰥔 ";
      interval = "999999999999";
      tooltip-format = "{:%A, %B %d, %Y (%R)}";
    };
    "clock#minute" = {
      format = "{:%M}";
      tooltip-format = "{:%A, %B %d, %Y (%R)}";
    };
    "clock#sep" = {
      format = " ";
      interval = "999999999999";
      tooltip-format = "{:%A, %B %d, %Y (%R)}";
    };
    "custom/notification" = {
      escape = true;
      exec = "swaync-client --subscribe-waybar";
      exec-if = "which swaync-client";
      format = "{icon}";
      format-icons = {
        dnd-inhibited-none = "";
        dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>";
        dnd-none = "";
        dnd-notification = "<span foreground='red'><sup></sup></span>";
        inhibited-none = "";
        inhibited-notification = "<span foreground='red'><sup></sup></span>";
        none = "";
        notification = "<span foreground='red'><sup></sup></span>";
      };
      on-click = "swaync-client --toggle-panel --skip-wait";
      on-click-right = "swaync-client --toggle-dnd --skip-wait";
      return-type = "json";
      tooltip = false;
    };
    height = 1440;
    "hyprland/window" = {
      format = "{title}";
      icon = true;
      rotate = 270;
    };
    idle_inhibitor = {
      format = "{icon}";
      format-icons = {
        activated = "󰅶";
        deactivated = "󰾫";
      };
    };
    keyboard-state = {
      capslock = true;
      format = "{icon}";
      format-icons = {
        locked = "";
        unlocked = "";
      };
      numlock = true;
    };
    layer = "top";
    modules-center = [ "hyprland/window" ];
    modules-left = [
      "custom/notification"
      "hyprland/workspaces"
    ];
    modules-right = [
      "backlight"
      "pulseaudio/slider"
      "pulseaudio"
      "idle_inhibitor"
      "clock#icon"
      "clock#hour"
      "clock#sep"
      "clock#minute"
      "tray"
      "battery"
    ];
    position = "right";
    pulseaudio = {
      format = "{icon}";
      format-bluetooth = "{icon}";
      format-icons = {
        default = [
          ""
          ""
        ];
      };
      format-muted = "";
      ignored-sinks = [ "Easy Effects Sink" ];
      on-click = "pavucontrol";
      scroll-step = 5;
      tooltip-format = "{volume}% - {desc}";
    };
    "pulseaudio/slider" = {
      orientation = "vertical";
    };
    reload_style_on_change = true;
    spacing = 0;
    tray = {
      icon-size = 21;
      spacing = 14;
    };
    width = 45;
  };
  # We will use our own waybar configuration
  stylix.targets.waybar.enable = false;
  home.packages = with pkgs; [
    brightnessctl
  ];
  xdg.configFile."wallust/templates/waybar.css".text = # css
    ''
      ${config.xdg.configFile."wallust/templates/gtk.css".text}

      window#waybar {
        background-color: alpha(@background, 0.65);
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
      }

      #workspaces button.visible {
        border-bottom-color: @cursor;
        border-bottom-width: 0.25rem;
        border-radius: 0.25rem;
      }

      #window {
        padding-bottom: 2rem;
        padding-top: 2rem;
        color: @foreground;
      }

      #workspaces button {
        padding-top: 0.5rem;
      }

      #workspaces button:hover {
        background-color: @color1;
        color: @foreground;
        border-radius: 0;
      }

      #pulseaudio-slider {
        min-height: 5rem;
        min-width: 0px;
      }

      #pulseaudio-slider through {
        background-color: @background;
      }

      #pulseaudio-slider highlight {
        background-color: @cursor;
      }

      #pulseaudio {
        padding-top: 0.5rem;
        padding-bottom: 0.5rem;
        padding-right: 0.66rem; /* The icon is a bit misaligned */
        font-size: 1rem;
        color: @foreground;
      }

      #pulseaudio:hover {
        background-color: @cursor;
        color: @background;
      }

      #tray {
        margin-top: 1rem;
        margin-bottom: 1.2rem;
      }

      #idle_inhibitor {
        padding-bottom: 0.5rem;
        padding-top: 0.5rem;
        padding-right: 0.66rem; /* The icon is a bit misaligned */
        color: @foreground;
      }

      #idle_inhibitor.activated {
        color: @cursor;
      }

      #idle_inhibitor:hover {
        background-color: @cursor;
        color: @background;
      }

      #custom-notification {
        margin-top: 0.5rem;
        font-size: 1.4rem;
        color: @foreground;
      }

      #clock.icon,
      #clock.hour,
      #clock.sep,
      #clock.minute {
        margin-left: 0.5rem;
        margin-right: 0.5rem;
      }

      #clock.icon {
        margin-top: 0.8rem;
        font-size: 1.4rem;
        padding-right: 0.25rem;
        background-color: alpha(@cursor, 0.5);
        border-top-left-radius: 4rem;
        border-top-right-radius: 4rem;
        padding-top: 0.25rem;
        color: @foreground;
      }

      #clock.hour,
      #clock.sep {
        padding-top: 0.4rem;
        font-size: 1.1rem;
        background-color: alpha(@cursor, 0.5);
        color: @foreground;
      }

      #clock.minute {
        padding-top: 0.4rem;
        font-size: 1.1rem;
        background-color: alpha(@cursor, 0.5);
        border-bottom-left-radius: 4rem;
        border-bottom-right-radius: 4rem;
        padding-bottom: 0.5rem;
        color: @foreground;
      }
    '';
  programs.wallust.settings.templates.waybar = {
    src = "waybar.css";
    dst = "${config.xdg.configHome}/waybar/style.css";
  };
  systemd.user.services.waybar = {
    Unit = {
      Description = "Waybar";
      After = [ config.wayland.systemd.target ];
      PartOf = [ config.wayland.systemd.target ];
    };
    Service = {
      ExecStartPre =
        pkgs.writeShellScript "wait-for-wallust" # sh
          ''
            while [ ! -f "${config.xdg.dataHome}/wallpapers/gtk.css" ]; do
              sleep 0.1
            done
          '';
      ExecStart = "${pkgs.waybar}/bin/waybar";
    };
    Install = {
      WantedBy = [ config.wayland.systemd.target ];
    };
  };
}
