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
          wasistlos: "com.github.xeco23.WasIstLos",
          spotify: "spotify-client",
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
    ../../window-manager/home-manager/sherlock
  ];

  wayland.windowManager.hyprland.settings = {
    bind = [
      "$mod, W, exec, ${pkgs.writeShellScript "select-hyprland-window-sherlock" ''
        selected=$(${pkgs.nodejs}/bin/node ${listHyprlandWindowJS} | ${config.programs.sherlock.package}/bin/sherlock)
        if [ -n "$selected" ]; then
          eval "$selected"
        fi
      ''}"
      "$mod, BackSpace, exec, sherlock --sub-menu pm"
      "$mod, A, exec, sherlock-select-audio"
      "$mod, C, exec, sherlock-clipboard"
      "$mod, S, exec, sherlock-systemd-user"
      "$mod, Z, exec, sherlock-zoxide"
      "$mod, N, exec, sherlock-zoxide neovide"
      "$mod, M, exec, sherlock-zoxide nemo"
      "$mod, D, exec, sherlock"
    ];
    layerrule = [
      "blur, sherlock"
      "ignorezero, sherlock"
      "ignorealpha 0.5, sherlock"
    ];
  };
}
