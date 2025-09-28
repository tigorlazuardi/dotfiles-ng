{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../../desktop/home-manager/vivaldi.nix
  ];
  programs.niri.settings.binds = {
    "Mod+b".action.spawn = [
      (lib.meta.getExe config.programs.vivaldi.package)
    ];
  };
  programs.niri.settings.window-rules = [
    {
      matches = [ { app-id = "vivaldi.*"; } ];
      open-maximized = true;
    }
    {
      matches = [
        {
          app-id = "vivaldi.*";
          title = "WhatsApp - Vivaldi";
        }
      ];
      block-out-from = "screencast"; # block from screen share but allow screenshots
    }
  ];

  systemd.user.services.niri-vivaldi-xdg-open = {
    Unit = rec {
      Description = "Niri Vivaldi xdg-open handler (auto focus)";
      After = [ config.wayland.systemd.target ];
      PartOf = After;
    };
    Install.WantedBy = [ config.wayland.systemd.target ];
    Service = {
      ExecStart = "${pkgs.writers.writeJS "niri-vivaldi-xdg-open" { } ''
        import net from "node:net";
        import { spawn } from "node:child_process";
        const socketAddress = process.env.NIRI_SOCKET;
        if (!socketAddress) {
          console.error(
            "NIRI_SOCKET environment variable is not set. Ensure this script is run in the Niri environment.",
          );
          process.exit(1);
        }
        const sock = net.createConnection(socketAddress);
        sock.on("connect", () => {
          console.log("Connected to Niri socket at", socketAddress);
          sock.write(JSON.stringify("EventStream") + "\n");
        });
        sock.on("data", (msg) => {
          for (const line of msg.toString().split("\n")) {
            if (!line.trim()) continue;
            const event = JSON.parse(line);
            if (!event.WindowOpenedOrChanged) continue;
            const win = event.WindowOpenedOrChanged.window;
            if (!win.app_id.startsWith("vivaldi-")) continue;
            if (win.is_focused) continue;
            console.log("Focusing Vivaldi window:", win);
            spawn(
              "niri",
              ["msg", "action", "focus-window", "--id", win.id.toString()],
              {
                timeout: 1000,
              },
            );
          }
        });
        sock.on("error", (err) => {
          console.error("Socket error:", err);
          process.exit(1);
        });
        sock.on("close", () => {
          process.exit(0);
        });
      ''}";
      Restart = "on-failure";
    };
  };
}
