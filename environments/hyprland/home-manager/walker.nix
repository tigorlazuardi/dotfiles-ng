{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  imports = [
    ../../window-manager/home-manager/walker.nix
  ];
  systemd.user.services.walker = {
    Unit = {
      PartOf = [ config.wayland.systemd.target ];
      After = [ config.wayland.systemd.target ];
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };
    Install.WantedBy = mkForce [
      config.wayland.systemd.target
    ];
  };
  programs.walker.config = {
    terminal = lib.mkForce (lib.meta.getExe' config.programs.foot.package "footclient");
    plugins = [
      (
        let
          python = lib.meta.getExe' pkgs.python3 "python";
          srcScript =
            pkgs.writeText "walker-hyprland-windows.py" # python
              ''
                import json
                import subprocess

                # Icon mappings for class names
                icon_mappings = {
                    "vivaldi-stable": "vivaldi",
                    "footclient": "foot"
                }

                # Get Hyprland clients
                result = subprocess.run(['hyprctl', 'clients', '-j'], capture_output=True, text=True)
                clients = json.loads(result.stdout)

                entries = []
                for client in clients:
                    class_name = client["class"].lower()
                    icon_name = icon_mappings.get(class_name, class_name)
                    
                    # Entry schema: https://github.com/abenz1267/walker/wiki/Plugins
                    # Follow the `json` tag of Entry struct.
                    entry = {
                        "label": client["title"],
                        "sub": f"Workspace {client['workspace']['name']} • {client['class']}",
                        "class": client["class"],
                        "initial_class": client["initialClass"],
                        "exec": f"hyprctl dispatch focuswindow address:{client['address']}",
                        "searchable": f"{client['title']} {client['class']} {client['initialClass']}",
                        "icon": icon_name
                    }
                    entries.append(entry)

                print(json.dumps(entries))
              '';
        in
        {
          name = "Hyprland Windows";
          placeholder = "Hyprland";
          show_icon_when_single = true;
          src = "${python} ${srcScript}";
          parser = "json";
          weight = 100;
        }
      )
    ];
  };
  wayland.windowManager.hyprland.settings = {
    bind = [
      "$mod, D, exec, ${meta.getExe config.programs.walker.package}"
    ];
  };
}
