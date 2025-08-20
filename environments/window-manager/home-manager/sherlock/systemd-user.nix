{
  config,
  pkgs,
  ...
}:
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
            exec: `systemd-run --user ${config.programs.sherlock.terminal} journalctl --user --pager-end --unit ''${systemdUnit}`,
          },
        },
        {
          title: `Follow ''${systemdUnit} Logs`,
          description: `''${entry.load} ''${entry.active} ''${entry.sub} · Follow ''${systemdUnit} logs`,
          field: "exec",
          hidden: {
            exec: `systemd-run --user ${config.programs.sherlock.terminal} journalctl --user --follow --unit ''${systemdUnit}`,
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
}
