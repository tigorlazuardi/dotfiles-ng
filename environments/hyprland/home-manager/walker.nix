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
      {
        name = "Hyprland Windows";
        placeholder = "Hyprland";
        show_icon_when_single = true;
        show_sub_when_single = true;
        src = pkgs.writers.writeJS "walker-hyprland-windows" { } ''
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
          const entries = output.map((client) => {
            const iconName = client.class.toLowerCase();
            // Schema => https://github.com/abenz1267/walker/blob/f5dd218b9e05f867af7420e960d7852242650ca9/internal/util/misc.go#L22
            return {
              label: client.title,
              sub: `Workspace ''${client.workspace.name} • ''${client.class}`,
              class: client.class,
              initial_class: client.initialClass,
              exec: `hyprctl dispatch focuswindow address:''${client.address}`,
              searchable: `''${client.title} ''${client.class} ''${client.initialClass}`,
              icon: iconMappings[iconName] || iconName,
              recalculate_score: true,
            };
          });
          console.log(JSON.stringify(entries));
        '';
        parser = "json";
        weight = 100;
        recalculate_score = true;
      }
    ];
  };
  wayland.windowManager.hyprland.settings = {
    bind = [
      "$mod, BackSpace, exec, ${meta.getExe config.programs.walker.package} --modules='Session'"
      # "$mod, W, exec, ${meta.getExe config.programs.walker.package} --modules='Hyprland Windows'"
      "$mod, D, exec, ${meta.getExe config.programs.walker.package}"
    ];
    layerrule = [
      "blur, walker"
      "ignorezero, walker"
      "ignorealpha 0.5, walker"
    ];
  };
}
