{
  config,
  pkgs,
  ...
}:
let
  serviceIcon =
    pkgs.writeText "home-gear.svg" # svg
      ''
        <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" fill="#ffffff" stroke="#ffffff">
          <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
          <g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g>
          <g id="SVGRepo_iconCarrier">
            <g>
              <path d="M0 0h24v24H0z" fill="none"></path>
              <path d="M19 21H5a1 1 0 0 1-1-1v-9H1l10.327-9.388a1 1 0 0 1 1.346 0L23 11h-3v9a1 1 0 0 1-1 1zM6 19h12V9.157l-6-5.454-6 5.454V19zm2.591-5.191a3.508 3.508 0 0 1 0-1.622l-.991-.572 1-1.732.991.573a3.495 3.495 0 0 1 1.404-.812V8.5h2v1.144c.532.159 1.01.44 1.404.812l.991-.573 1 1.731-.991.573a3.508 3.508 0 0 1 0 1.622l.991.572-1 1.731-.991-.572a3.495 3.495 0 0 1-1.404.811v1.145h-2V16.35a3.495 3.495 0 0 1-1.404-.811l-.991.572-1-1.73.991-.573zm3.404.688a1.5 1.5 0 1 0 0-2.998 1.5 1.5 0 0 0 0 2.998z"></path>
            </g>
          </g>
        </svg>
      '';
  viewIcon =
    pkgs.writeText "magnifying-glass.svg" # svg
      ''
        <svg fill="#ffffff" height="200px" width="200px" version="1.2" baseProfile="tiny" id="Layer_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 256 256" xml:space="preserve" stroke="#ffffff">
          <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
          <g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g>
          <g id="SVGRepo_iconCarrier">
            <path d="M256,229.484l-81.427-81.427c9.903-14.981,15.679-32.917,15.679-52.181C190.253,43.562,147.691,1,95.376,1 S0.5,43.562,0.5,95.876s42.562,94.876,94.876,94.876c19.521,0,37.683-5.929,52.783-16.077L229.484,256L256,229.484z M20.5,95.876 C20.5,54.589,54.089,21,95.376,21c41.287,0,74.876,33.589,74.876,74.876c0,41.287-33.59,74.876-74.876,74.876 C54.089,170.753,20.5,137.163,20.5,95.876z"></path>
          </g>
        </svg>
      '';
  tailIcon =
    pkgs.writeText "monitor.svg" # svg
      ''
        <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" stroke="#ffffff">
          <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
          <g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g>
          <g id="SVGRepo_iconCarrier">
            <path fill-rule="evenodd" clip-rule="evenodd" d="M12 3.53846C9.81823 3.53846 6.83216 3.73771 4.98341 3.87978C4.38263 3.92595 3.91003 4.39142 3.85543 4.98718C3.71478 6.52149 3.53846 8.78459 3.53846 10.4615C3.53846 12.1385 3.71478 14.4016 3.85543 15.9359C3.91003 16.5317 4.38263 16.9971 4.98341 17.0433C6.83216 17.1854 9.81823 17.3846 12 17.3846C14.1818 17.3846 17.1678 17.1854 19.0166 17.0433C19.6174 16.9971 20.09 16.5317 20.1446 15.9359C20.2852 14.4016 20.4615 12.1385 20.4615 10.4615C20.4615 8.78459 20.2852 6.52149 20.1446 4.98718C20.09 4.39142 19.6174 3.92595 19.0166 3.87978C17.1678 3.73771 14.1818 3.53846 12 3.53846ZM4.86553 2.34584C6.715 2.20371 9.75334 2 12 2C14.2467 2 17.285 2.20371 19.1345 2.34584C20.4791 2.44917 21.5531 3.49951 21.6766 4.84675C21.8175 6.38385 22 8.70808 22 10.4615C22 12.215 21.8175 14.5392 21.6766 16.0763C21.5531 17.4236 20.4791 18.4739 19.1345 18.5772C17.285 18.7194 14.2467 18.9231 12 18.9231C9.75334 18.9231 6.715 18.7194 4.86553 18.5772C3.52091 18.4739 2.44688 17.4236 2.32339 16.0763C2.18249 14.5392 2 12.215 2 10.4615C2 8.70808 2.18249 6.38385 2.32339 4.84675C2.44688 3.49951 3.52091 2.44917 4.86553 2.34584Z" fill="#030D45"></path>
            <path fill-rule="evenodd" clip-rule="evenodd" d="M16.6465 7.35351C16.9469 7.65391 16.9469 8.14096 16.6465 8.44136L13.5696 11.5183C13.2692 11.8187 12.7821 11.8187 12.4817 11.5183L10.9744 10.0109L8.44136 12.5439C8.14096 12.8443 7.65391 12.8443 7.35351 12.5439C7.0531 12.2435 7.0531 11.7565 7.35351 11.4561L10.4304 8.37915C10.7308 8.07875 11.2179 8.07875 11.5183 8.37915L13.0256 9.8865L15.5586 7.35351C15.859 7.0531 16.3461 7.0531 16.6465 7.35351Z" fill="#030D45"></path>
            <path fill-rule="evenodd" clip-rule="evenodd" d="M7.12821 21.2308C7.12821 20.8059 7.4726 20.4615 7.89744 20.4615H16.1026C16.5274 20.4615 16.8718 20.8059 16.8718 21.2308C16.8718 21.6556 16.5274 22 16.1026 22H7.89744C7.4726 22 7.12821 21.6556 7.12821 21.2308Z" fill="#030D45"></path>
          </g>
        </svg>
      '';
  startIcon =
    pkgs.writeText "play.svg" # svg
      ''
        <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" stroke="#ffffff">
          <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
          <g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g>
          <g id="SVGRepo_iconCarrier">
            <path fill-rule="evenodd" clip-rule="evenodd" d="M11.0748 7.50835C9.74622 6.72395 8.25 7.79065 8.25 9.21316V14.7868C8.25 16.2093 9.74622 17.276 11.0748 16.4916L15.795 13.7048C17.0683 12.953 17.0683 11.047 15.795 10.2952L11.0748 7.50835ZM9.75 9.21316C9.75 9.01468 9.84615 8.87585 9.95947 8.80498C10.0691 8.73641 10.1919 8.72898 10.3122 8.80003L15.0324 11.5869C15.165 11.6652 15.25 11.8148 15.25 12C15.25 12.1852 15.165 12.3348 15.0324 12.4131L10.3122 15.2C10.1919 15.271 10.0691 15.2636 9.95947 15.195C9.84615 15.1242 9.75 14.9853 9.75 14.7868V9.21316Z" fill="#000000"></path>
            <path fill-rule="evenodd" clip-rule="evenodd" d="M12 1.25C6.06294 1.25 1.25 6.06294 1.25 12C1.25 17.9371 6.06294 22.75 12 22.75C17.9371 22.75 22.75 17.9371 22.75 12C22.75 6.06294 17.9371 1.25 12 1.25ZM2.75 12C2.75 6.89137 6.89137 2.75 12 2.75C17.1086 2.75 21.25 6.89137 21.25 12C21.25 17.1086 17.1086 21.25 12 21.25C6.89137 21.25 2.75 17.1086 2.75 12Z" fill="#000000"></path>
          </g>
        </svg>
      '';
  restartIcon =
    pkgs.writeText "restart.svg" # svg
      ''
        <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" stroke="#ffffff">
          <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
          <g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g>
          <g id="SVGRepo_iconCarrier">
            <g clip-path="url(#clip0_1276_7761)">
              <path d="M19.7285 10.9288C20.4413 13.5978 19.7507 16.5635 17.6569 18.6573C15.1798 21.1344 11.4826 21.6475 8.5 20.1966M18.364 8.05071L17.6569 7.3436C14.5327 4.21941 9.46736 4.21941 6.34316 7.3436C3.42964 10.2571 3.23318 14.8588 5.75376 18M18.364 8.05071H14.1213M18.364 8.05071V3.80807" stroke="#ffffff" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"></path>
            </g>
            <defs>
              <clipPath id="clip0_1276_7761">
                <rect width="24" height="24" fill="white"></rect>
              </clipPath>
            </defs>
          </g>
        </svg>
      '';
  stopIcon =
    pkgs.writeText "stop.svg" # svg
      ''
        <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
          <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
          <g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g>
          <g id="SVGRepo_iconCarrier">
            <circle cx="12" cy="12" r="10" stroke="#ffffff" stroke-width="1.5"></circle>
            <path d="M8 12C8 10.1144 8 9.17157 8.58579 8.58579C9.17157 8 10.1144 8 12 8C13.8856 8 14.8284 8 15.4142 8.58579C16 9.17157 16 10.1144 16 12C16 13.8856 16 14.8284 15.4142 15.4142C14.8284 16 13.8856 16 12 16C10.1144 16 9.17157 16 8.58579 15.4142C8 14.8284 8 13.8856 8 12Z" stroke="#ffffff" stroke-width="1.5"></path>
          </g>
        </svg>
      '';
in
{
  programs.sherlock.launchers = [
    {
      name = "Systemd User Services";
      priority = 1200;
      type = "command";
      shortcut = true;
      args.commands."Systemd User" = {
        exec = "sherlock-systemd-user";
        icon = serviceIcon;
        search_string = "systemd;services;units;user";
      };
      actions = [
        {
          name = "Clear Failed Units";
          icon = serviceIcon;
          method = "command";
          exec = "systemctl --user reset-failed";
        }
        {
          name = "List Units";
          icon = serviceIcon;
          method = "command";
          exec = "sherlock-systemd-user";
        }
      ];
    }
  ];
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
        icon: "${serviceIcon}",
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
          icon: "${viewIcon}",
          hidden: {
            exec: `systemd-run --user ${config.programs.sherlock.terminal} journalctl --user --pager-end --unit ''${systemdUnit}`,
          },
        },
        {
          title: `Follow ''${systemdUnit} Logs`,
          description: `''${entry.load} ''${entry.active} ''${entry.sub} · Follow ''${systemdUnit} logs`,
          field: "exec",
          icon: "${tailIcon}",
          hidden: {
            exec: `systemd-run --user ${config.programs.sherlock.terminal} journalctl --user --follow --unit ''${systemdUnit}`,
          },
        },
        {
          title: `Start ''${systemdUnit}`,
          description: `''${entry.load} ''${entry.active} ''${entry.sub} · Start (activate) ''${systemdUnit}`,
          field: "exec",
          icon: "${startIcon}",
          hidden: {
            exec: `systemctl --user start ''${systemdUnit}`,
          },
        },
        {
          title: `Restart ''${systemdUnit}`,
          description: `''${entry.load} ''${entry.active} ''${entry.sub} · Start or restart ''${systemdUnit}`,
          field: "exec",
          icon: "${restartIcon}",
          hidden: {
            exec: `systemctl --user restart ''${systemdUnit}`,
          },
        },
        {
          title: `Stop ''${systemdUnit}`,
          description: `''${entry.load} ''${entry.active} ''${entry.sub} · Stop ''${systemdUnit}`,
          field: "exec",
          icon: "${stopIcon}",
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
