{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  imports = [
    ../../window-manager/home-manager/sherlock.nix
  ];

  # programs.sherlock.launcher = [
  #   (
  #     let
  #       python = lib.meta.getExe' pkgs.python3 "python";
  #       srcScript =
  #         pkgs.writeText "walker-hyprland-windows.py" # python
  #           ''
  #             import json
  #             import subprocess
  #
  #             # Icon mappings for class names
  #             icon_mappings = {
  #                 "vivaldi-stable": "vivaldi",
  #                 "footclient": "foot"
  #             }
  #
  #             # Get Hyprland clients
  #             result = subprocess.run(['hyprctl', 'clients', '-j'], capture_output=True, text=True)
  #             clients = json.loads(result.stdout)
  #
  #             entries = []
  #             for client in clients:
  #                 class_name = client["class"].lower()
  #                 icon_name = icon_mappings.get(class_name, class_name)
  #
  #                 # Entry schema: https://github.com/abenz1267/walker/wiki/Plugins
  #                 # Follow the `json` tag of Entry struct.
  #                 entry = {
  #                     "title": client["title"],
  #                     "content":  f"Workspace {client['workspace']['name']} • {client['class']}",
  #                     "result": json.dumps(client),
  #                     "actions": [
  #                       {
  #                         "name": "focus",
  #                         "exec": f"hyprctl dispatch focuswindow address:{client['address']}",
  #                         "icon": icon_name,
  #                         "method": "command",
  #                         "exit": True,
  #                       },
  #                     ],
  #                 }
  #                 entries.append(entry)
  #
  #             print(json.dumps(entries))
  #           '';
  #     in
  #     {
  #       name = "Hyprland Windows";
  #       alias = "hypr";
  #       async = true;
  #       priority = 1000;
  #       spawn_focus = true;
  #       args = {
  #         icon = "window";
  #         exec = python;
  #         exec-args = srcScript;
  #       };
  #     }
  #   )
  # ];

  wayland.windowManager.hyprland.settings.bind = [
    "$mod, D, exec, sherlock"
  ];
}
