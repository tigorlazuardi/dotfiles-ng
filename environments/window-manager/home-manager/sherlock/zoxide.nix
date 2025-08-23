{
  config,
  pkgs,
  ...
}:
let
  neovideIcon = pkgs.fetchurl {
    url = "https://neovide.dev/favicon.svg";
    hash = "sha256-pocDkd7QkMxfJPDLQKj/pnkw+vEJpBl1PsJawKAxd6k=";
  };
  termIcon =
    pkgs.writeText "term.svg" # svg
      ''
        <svg fill="#ffffff" viewBox="0 0 32 32" version="1.1" xmlns="http://www.w3.org/2000/svg">
          <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
          <g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g>
          <g id="SVGRepo_iconCarrier">
            <title>console</title>
            <path d="M0 26.016v-20q0-2.496 1.76-4.256t4.256-1.76h20q2.464 0 4.224 1.76t1.76 4.256v20q0 2.496-1.76 4.224t-4.224 1.76h-20q-2.496 0-4.256-1.76t-1.76-4.224zM4 26.016q0 0.832 0.576 1.408t1.44 0.576h20q0.8 0 1.408-0.576t0.576-1.408v-20q0-0.832-0.576-1.408t-1.408-0.608h-20q-0.832 0-1.44 0.608t-0.576 1.408v20zM8 18.016h2.016v-2.016h-2.016v2.016zM8 10.016h2.016v-2.016h-2.016v2.016zM10.016 16h1.984v-1.984h-1.984v1.984zM10.016 12h1.984v-1.984h-1.984v1.984zM12 14.016h2.016v-2.016h-2.016v2.016zM14.016 18.016h5.984v-2.016h-5.984v2.016z"></path>
          </g>
        </svg>
      '';
in
{
  programs.sherlock.launchers = [
    {
      name = "Open Directory in Terminal/Neovide";
      type = "command";
      priority = 1200;
      args.commands = {
        Zoxide = {
          icon = "${termIcon}";
          exec = "sherlock-zoxide";
          search_string = "zoxide;z;cd;jump;project;dir";
        };
        "Zoxide (Neovide)" = {
          icon = "${neovideIcon}";
          exec = "sherlock-zoxide neovide";
          search_string = "zoxide;z;cd;jump;project;dir;neovide";
        };
      };
    }
  ];
  home.packages = [
    (pkgs.writers.writeJSBin "sherlock-zoxide" { } ''
      import { spawnSync } from "node:child_process";
      const launcher = (process.argv[2] || "").toLowerCase();
      const result = spawnSync("zoxide", ["query", "--list", "--score"]);
      if (result.error) {
        console.error("Error running zoxide query --list --score:", result.error);
        process.exit(1);
      }
      let icon;
      switch (launcher) {
        case "neovide":
          icon = "${neovideIcon}";
          break;
        default:
          icon = "${termIcon}";
          break;
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
          icon: icon,
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
