{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    # Waybar has dependency with swaync
    ./swaync.nix
    ./wpaperd.nix

    ./wallust
  ];
  # We will use lib.mkMerge to ensure css rules are applied in the correct order when
  # the css rules are merged.
  config = lib.mkMerge [
    {
      # This snippet of text must be placed before any other css rules.
      xdg.configFile."wallust/templates/waybar.css".text =
        lib.mkBefore # css
          ''
            /* cannot use import url because waybar does not react to changes of imported files */
            ${config.xdg.configFile."wallust/templates/gtk.css".text}
          '';
    }
    {
      programs.waybar.enable = true;
      programs.waybar.settings.main = {
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
        # height = 1440;
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
        modules-right = [
          "backlight"
          "pulseaudio"
          "idle_inhibitor"
          "clock#icon"
          "clock#hour"
          "clock#sep"
          "clock#minute"
          "tray"
          "battery"
        ];
        # position = "top";
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
        # width = 45;
      };
      # We will use our own waybar configuration
      # stylix.targets.waybar.enable = false;
      home.packages = with pkgs; [
        brightnessctl
      ];
      xdg.configFile."wallust/templates/waybar.css".text = # css
        ''
          window#waybar {
            background-color: alpha(@background, 0.65);
            color: @foreground;
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
            padding-left: 1rem;
            color: @foreground;
            font-size: 1.2rem;
          }

          #idle_inhibitor.activated {
            color: @cursor;
          }

          #idle_inhibitor:hover {
            background-color: @cursor;
            color: @background;
          }

          #custom-notification {
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
                while [ ! -f "${config.xdg.configHome}/waybar/style.css" ]; do
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
  ];
}
