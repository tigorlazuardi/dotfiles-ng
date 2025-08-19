{
  config,
  pkgs,
  ...
}:
let
  listHyprlandWindowJS =
    pkgs.writeText "list-hyprland-windows.mjs" # javascript
      ''
        import { spawnSync } from "node:child_process";

        const result = spawnSync("hyprctl", ["clients", "-j"]);
        if (result.error) {
          console.error("Error executing hyprctl clients -j:", result.error);
          process.exit(1);
        }
        const output = JSON.parse(result.stdout.toString());
        const iconMappings = {
          "vivaldi-stable": "vivaldi",
          footclient: "foot",
        };
        const elements = output.map((client) => ({
          title: client.title,
          icon: (() => {
            const clientClass = client.class.toLowerCase();
            return iconMappings[clientClass] || clientClass;
          })(),
          icon_size: 64,
          description: `Workspace ''${client.workspace.name} · ''${client.class}`,
          field: "exec",
          method: "print",
          hidden: {
            exec: `hyprctl dispatch focuswindow address:''${client.address}`,
          },
        }));
        console.log(
          JSON.stringify({
            settings: [],
            elements,
          }),
        );
      '';
in
{
  imports = [
    ../../window-manager/home-manager/sherlock.nix
  ];

  wayland.windowManager.hyprland.settings.bind = [
    "$mod, W, exec, ${pkgs.writeShellScript "select-hyprland-window-sherlock" ''
      selected=$(${pkgs.nodejs}/bin/node ${listHyprlandWindowJS} | ${config.programs.sherlock.package}/bin/sherlock)
      if [ -n "$selected" ]; then
        eval "$selected"
      fi
    ''}"
    "$mod, S, exec, sherlock-systemd-user"
    # "$mod, D, exec, sherlock"
  ];
}
