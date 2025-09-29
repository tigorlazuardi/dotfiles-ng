{ config, pkgs, ... }:
let
  findWindowJS = pkgs.writers.writeJS "findNiriWindow" { } ''
    import { spawnSync } from "node:child_process";

    const result = spawnSync("niri", ["msg", "--json", "windows"]);
    if (result.error) {
      console.error("Error executing niri msg:", result.error);
      process.exit(1);
    }
    const clients = JSON.parse(result.stdout);
    const iconMappings = {
      "vivaldi-stable": "vivaldi",
      footclient: "foot",
      wasistlos: "com.github.xeco23.WasIstLos",
      spotify: "spotify-client",
    };
    const elements = clients.map((client) => ({
      title: client.title,
      icon: (() => {
        const clientClass = client.app_id.toLowerCase();
        return iconMappings[clientClass] || clientClass;
      })(),
      icon_size: 64,
      description: `Workspace ''${client.workspace_id} · ''${client.app_id}`,
      field: "id",
      method: "print",
      hidden: {
        id: client.id.toString(),
      },
    }));
    const selectedResult = spawnSync("sherlock", [], {
      input: JSON.stringify({ elements }),
    });
    const id = selectedResult.stdout.toString().trim();
    if (!id) {
      process.exit(0);
    }
    spawnSync("niri", ["msg", "action", "focus-window", "--id", id]);
  '';
in
{
  imports = [
    ../../window-manager/home-manager/sherlock
  ];
  programs.niri.settings.layer-rules = [
    {
      matches = [
        { namespace = "sherlock"; }
      ];
      shadow = {
        enable = true;
        softness = 40;
        spread = 5;
        offset = {
          x = 0;
          y = 0;
        };
        draw-behind-window = true;
        color = "#00000099";
      };
    }
  ];

  programs.niri.settings.binds = with config.lib.niri.actions; {
    "Mod+BackSpace".action = spawn "sherlock" "--sub-menu" "pm";
    "mod+f".action = spawn "${findWindowJS}";
    "mod+a".action = spawn "sherlock-select-audio";
    "mod+c".action = spawn "sherlock-clipboard";
    "mod+s".action = spawn "sherlock-systemd-user";
    "mod+z".action = spawn "sherlock-zoxide";
    "mod+n".action = spawn "sherlock-zoxide" "neovide";
    "mod+m".action = spawn "sherlock-zoxide" "nemo";
    "mod+d".action = spawn "sherlock";
  };
}
