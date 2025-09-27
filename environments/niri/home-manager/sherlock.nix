{ pkgs, ... }:
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

  programs.niri.extraConfigPost = # kdl
    ''
      layer-rule {
        match namespace="sherlock"

        shadow {
          on
          softness 40
          spread 5
          offset x=0 y=0
          draw-behind-window true
          color "#00000099"
        }
      }
    '';

  programs.niri.settings.binds = {
    "Mod+BackSpace" = {
      _props.repeat = false;
      spawn = [
        "sherlock"
        "--sub-menu"
        "pm"
      ];
    };
    "Mod+f" = {
      _props.repeat = false;
      spawn = "${findWindowJS}";
    };
    "Mod+z" = {
      _props.repeat = false;
      spawn = "sherlock-select-audio";
    };
    "Mod+c" = {
      _props.repeat = false;
      spawn = "sherlock-clipboard";
    };
    "Mod+t" = {
      _props.repeat = false;
      spawn = "sherlock-systemd-user";
    };
    "Mod+v" = {
      _props.repeat = false;
      spawn = "sherlock-zoxide";
    };
    "Mod+n" = {
      _props.repeat = false;
      spawn = [
        "sherlock-zoxide"
        "neovide"
      ];
    };
    "Mod+m" = {
      _props.repeat = false;
      spawn = [
        "sherlock-zoxide"
        "nemo"
      ];
    };
    "Mod+r" = {
      _props.repeat = false;
      spawn = "sherlock";
    };
  };
}
