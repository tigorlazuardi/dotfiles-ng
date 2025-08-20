{
  config,
  pkgs,
  ...
}:
{
  home.packages = [
    (pkgs.writers.writeJSBin "sherlock-zoxide" { } ''
      import { spawnSync } from "node:child_process";
      const launcher = (process.argv[2] || "").toLowerCase();
      const result = spawnSync("zoxide", ["query", "--list", "--score"]);
      if (result.error) {
        console.error("Error running zoxide query --list --score:", result.error);
        process.exit(1);
      }
      const elements = [];
      for (const line of result.stdout.toString().split("\n")) {
        const l = line.trim();
        if (l === "") continue; // Skip empty lines
        const [score, path] = l.split(" ");
        let s = parseFloat(score);
        if (isNaN(s)) s = 0;
        elements.push({
          title: path,
          description: `Score: ''${s}`,
        });
      }
      const cmd = spawnSync("sherlock", ["--field", launcher], {
        input: JSON.stringify({ elements }),
      });
      if (cmd.error) {
        console.error(`Error executing sherlock --field ''${launcher}:`, cmd.error);
        process.exit(1);
      }
      const path = cmd.stdout.toString().trim();
      if (path === "") {
        process.exit(0);
      }
      switch (launcher) {
        case "neovide":
          // Use Neovide with the specified path
          spawnSync(
            "systemd-run",
            [
              "--user",
              "--working-directory",
              path,
              "${config.programs.neovide.package}/bin/neovide",
              "--no-fork",
            ],
            { stdio: "inherit" },
          );
          break;
        default:
          // Use Foot terminal with the specified path
          spawnSync(
            "systemd-run",
            [
              "--user",
              `${config.programs.sherlock.terminal}`,
              "--working-directory",
              path,
              "--title",
              `Foot - ''${path}`,
            ],
            { stdio: "inherit" },
          );
          break;
      }
    '')
  ];
}
