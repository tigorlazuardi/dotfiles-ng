{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  terminalLaunchPrefix =
    if config.programs.foot.server.enable then
      lib.meta.getExe' config.programs.foot.package "footclient"
    else
      lib.meta.getExe config.programs.foot.package;
in
{
  home.packages = [
    (pkgs.writers.writeJSBin "sherlock-systemd-user" { } ''
      import { spawnSync } from "node:child_process";

      const result = spawnSync("systemctl", [
        "--user",
        "list-units",
        "--type=service",
        "--all",
        "--output=json",
      ]);
      if (result.error) {
        console.error(
          "Error executing systemctl --user list-units --type=service --all --output=json:",
          result.error,
        );
        process.exit(1);
      }
      const output = JSON.parse(result.stdout.toString());
      const elements = output.map((unit) => ({
        title: unit.unit,
        description: `''${unit.load} ''${unit.active} ''${unit.sub} · ''${unit.description}`,
      }));
      const systemdUnitResult = spawnSync("sherlock", [], {
        input: JSON.stringify({ elements }),
      });
      if (systemdUnitResult.error) {
        console.error("Error executing sherlock:", systemdUnitResult.error);
        process.exit(1);
      }
      const systemdUnit = systemdUnitResult.stdout.toString().trim();
      if (systemdUnit === "") {
        process.exit(0);
      }
      const entry = output.find((unit) => unit.unit === systemdUnit);
      const actions = [
        {
          title: `View ''${systemdUnit} Logs`,
          description: `''${entry.load} ''${entry.active} ''${entry.sub} · View ''${systemdUnit} logs`,
          field: "exec",
          hidden: {
            exec: `systemd-run --user ${terminalLaunchPrefix} journalctl --user --pager-end --unit ''${systemdUnit}`,
          },
        },
        {
          title: `Follow ''${systemdUnit} Logs`,
          description: `''${entry.load} ''${entry.active} ''${entry.sub} · Follow ''${systemdUnit} logs`,
          field: "exec",
          hidden: {
            exec: `systemd-run --user ${terminalLaunchPrefix} journalctl --user --follow --unit ''${systemdUnit}`,
          },
        },
        {
          title: `Start ''${systemdUnit}`,
          description: `''${entry.load} ''${entry.active} ''${entry.sub} · Start (activate) ''${systemdUnit}`,
          field: "exec",
          hidden: {
            exec: `systemctl --user start ''${systemdUnit}`,
          },
        },
        {
          title: `Restart ''${systemdUnit}`,
          description: `''${entry.load} ''${entry.active} ''${entry.sub} · Start or restart ''${systemdUnit}`,
          field: "exec",
          hidden: {
            exec: `systemctl --user restart ''${systemdUnit}`,
          },
        },
        {
          title: `Stop ''${systemdUnit}`,
          description: `''${entry.load} ''${entry.active} ''${entry.sub} · Stop ''${systemdUnit}`,
          field: "exec",
          hidden: {
            exec: `systemctl --user stop ''${systemdUnit}`,
          },
        },
      ];
      const actionResult = spawnSync("sherlock", [], {
        input: JSON.stringify({ elements: actions }),
      });
      const cmd = actionResult.stdout.toString().trim();
      if (cmd === "") {
        process.exit(0);
      }
      spawnSync("bash", ["-c", cmd]);
    '')
  ];
  programs.sherlock = {
    enable = true;
    package = inputs.sherlock.packages.${pkgs.system}.default;
    settings = {
      default_apps = {
        terminal =
          if (config.programs.foot.server.enable) then
            "${config.programs.foot.package}/bin/footclient"
          else
            "${config.programs.foot.package}/bin/foot";
        browser = "${config.programs.vivaldi.package}/bin/vivaldi %u";
      };
      behavior = {
        use_xdg_data_dir_icons = true;
        global_prefix = "systemd-run --user ";
      };
    };
    systemd.enable = false; # sherlock daemon mode is not good enough for normal usage yet.
    launchers = [
      {
        name = "App Launcher";
        alias = "app";
        type = "app_launcher";
        args = { };
        priority = 3;
        home = "Home";
      }
      {
        name = "Kill Process";
        alias = "kill";
        type = "process";
        args = { };
        priority = 0;
      }
      {
        name = "Media Player";
        type = "audio_sink";
        async = true;
        home = "Home";
        priority = 1;
        actions =
          let
            playerctl = lib.meta.getExe pkgs.playerctl;
          in
          [
            {
              name = "Skip";
              icon = "media-skip-forward";
              method = "command";
              exec = "${playerctl} next";
              exit = true;
            }
            {
              name = "Previous";
              icon = "media-skip-backward";
              method = "command";
              exec = "${playerctl} previous";
              exit = true;
            }
            {
              name = "Play/Pause";
              icon = "media-play-pause";
              method = "command";
              exec = "${playerctl} play-pause";
              exit = true;
            }
          ];
      }
      {
        name = "Web Search";
        display_name = "Google Search";
        tag_start = "{keyword}";
        alias = "g";
        type = "web_launcher";
        args = {
          search_engine = "google";
          icon = "google";
        };
        priority = 100;
      }
    ];
  };
}
