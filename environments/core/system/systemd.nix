{
  user,
  pkgs,
  ...
}:
{
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=15m
  '';
  # When laptop lid is closed, suspend then hibernate.
  services.logind.lidSwitch = "suspend-then-hibernate";
  security.sudo.extraRules = [
    {
      users = [ user.name ];
      commands = [
        {
          command = "/run/current-system/sw/bin/systemctl";
          options = [
            "SETENV"
            "NOPASSWD"
          ];
        }
        {
          command = "/run/current-system/sw/bin/journalctl";
          options = [
            "SETENV"
            "NOPASSWD"
          ];
        }
      ];
    }
  ];
  environment.systemPackages = [
    (pkgs.writers.writeJSBin "systemctl-list-units" { } ''
      import { spawnSync } from "node:child_process";
      const isUser = (process.argv[2] || "").toLowerCase() === "user";
      const opts = ["list-units", "--type=service,timer,socket", "--output=json"];
      if (isUser) {
        opts.unshift("--user");
      }
      const unitsResult = spawnSync("systemctl", opts);
      const units = JSON.parse(unitsResult.stdout);
      // Target length for unit name column
      const unitNameTargetLength = units.reduce((unit, current) =>
        current.unit.length > unit.unit.length ? current : unit,
      ).unit.length;
      const entries = units.map((unit) => {
        const unitNamePadding = " ".repeat(unitNameTargetLength - unit.unit.length);
        const loadPadding = " ".repeat("loaded".length - unit.load.length);
        const activePadding = " ".repeat("active".length - unit.active.length);
        const subPadding = " ".repeat("listening".length - unit.sub.length);
        return `''${unit.unit}''${unitNamePadding} ''${unit.load}''${loadPadding} ''${unit.active}''${activePadding} ''${unit.sub}''${subPadding} ''${unit.description}`;
      });
      const selected = spawnSync("${pkgs.skim}/bin/sk", [], {
        input: entries.join("\n"),
        stdio: "pipe",
      });
      const entry = selected.stdout.toString().trim();
      if (!entry) process.exit(0);
      const unit = entry.split(" ")[0];
      const actions = [
        `View    ''${unit} Logs`,
        `Follow  ''${unit} Logs`,
        `Stop    ''${unit}`,
        `Start   ''${unit}`,
        `Restart ''${unit}`,
      ];
      const actionSelected = spawnSync("${pkgs.skim}/bin/sk", [], {
        input: actions.join("\n"),
        stdio: "pipe",
      });
      const actionValue = actionSelected.stdout.toString().trim();
      if (!actionValue) process.exit(0);
      const action = actionValue.split(" ")[0];
      let systemCommand = "";
      let systemArgs = [];
      switch (action) {
        case "View":
          systemCommand = "journalctl";
          systemArgs = ["--unit", unit, "--pager-end"];
          break;
        case "Follow":
          systemCommand = "journalctl";
          systemArgs.push("--follow", "--unit", unit);
          break;
        case "Stop":
          systemCommand = "systemctl";
          systemArgs = ["stop", unit];
          break;
        case "Start":
          systemCommand = "systemctl";
          systemArgs = ["start", unit];
          break;
        case "Restart":
          systemCommand = "systemctl";
          systemArgs = ["restart", unit];
          break;
        default:
          console.error("Unknown action:", action);
          process.exit(1);
      }
      if (isUser) {
        systemArgs.unshift("--user");
      } else {
        systemArgs.unshift(systemCommand);
        systemCommand = "sudo";
      }
      spawnSync(systemCommand, systemArgs, { stdio: "inherit" });
    '')
  ];
}
