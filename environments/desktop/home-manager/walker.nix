{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    inputs.walker.homeManagerModules.default
  ];

  programs.walker = {
    enable = true;
    runAsService = true;

    config = {
      builtins.applications.launch_prefix = "systemd-run --user ";
      builtins.runner.launch_prefix =
        let
          foot =
            if config.programs.foot.server.enable then
              lib.meta.getExe' config.programs.foot.package "footclient"
            else
              lib.meta.getExe config.programs.foot.package;
        in
        "${foot} ";
      builtins.websearch.entries = [
        {
          name = "Google";
          url = "https://www.google.com/search?q=%TERM%";
          prefix = "g ";
        }
        {
          name = "Noogle";
          prefix = "lib ";
          url = "https://noogle.dev/q?term=%TERM%";
        }
        {
          name = "Nixpkgs";
          prefix = "p ";
          url = "https://search.nixos.org/packages?channel=unstable&query=%TERM%";
        }
        {
          name = "Nix Options";
          prefix = "o ";
          url = "https://search.nixos.org/options?channel=unstable&query=%TERM%";
        }
        {
          name = "Home Manager Options";
          prefix = "hm ";
          url = "https://home-manager-options.extranix.com/?release=master&query=%TERM%";
        }
        {
          name = "YouTube";
          prefix = "yt ";
          url = "https://www.youtube.com/results?search_query=%TERM%";
        }
        {
          name = "Claude";
          prefix = "c ";
          url = "https://claude.ai/search?q=%TERM%";
        }
      ];
      terminal = "${lib.meta.getExe config.programs.ghostty.package}";
      keys = {
        next = [
          "down"
          "ctrl j"
          "ctrl n"
        ];
        prev = [
          "up"
          "ctrl k"
          "ctrl p"
        ];
      };
      plugins = [
        (
          let
            python = lib.meta.getExe' pkgs.python3 "python";
            pactl = lib.meta.getExe' pkgs.pulseaudio "pactl";
            speakerIcon = pkgs.fetchurl {
              url = "https://www.svgrepo.com/download/522673/speaker.svg";
              hash = "sha256-XDytdJGb7WhI89NWZmYeaFr/cB1BYzPmwYkZjrPnKNE=";
            };
            earphoneIcon = pkgs.fetchurl {
              url = "https://www.svgrepo.com/download/461261/earphone.svg";
              hash = "sha256-onU/+VXQFUCKutNLqytp4M2fT3i877cPk2KujieALUI=";
            };
            srcScript =
              pkgs.writeText "walker-audio.py" # python
                ''
                  import json
                  import subprocess

                  result = subprocess.run(['${pactl}', '-f', 'json', 'list', 'sinks'], capture_output=True, text=True)
                  sinks = json.loads(result.stdout)

                  icon_mappings = {
                    "KM-HIFI-384KHZ Analog Stereo": "${earphoneIcon}",
                  }

                  entries = []
                  for sink in sinks:
                      icon = icon_mappings.get(sink["description"], "${speakerIcon}")
                      # Entry schema: https://github.com/abenz1267/walker/wiki/Plugins
                      # Follow the `json` tag of Entry struct.
                      entry = {
                          "label": sink["description"],
                          "sub": f"State: {sink['state']} • {sink['name']}",
                          "name": sink["name"],
                          "description": sink["description"],
                          "exec": f"${pactl} set-default-sink {sink['name']}",
                          "searchable": f"{sink['description']} {sink['name']}",
                          "icon": icon
                      }
                      entries.append(entry)

                  print(json.dumps(entries))
                '';
          in
          {
            name = "audio";
            placeholder = "Select Audio Output";
            show_icon_when_single = true;
            src = "${python} ${srcScript}";
            parser = "json";
          }
        )
      ];
    };
  };

  dconf.settings = {
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/walker" = {
      name = "Walker";
      command = "${config.programs.walker.package}/bin/walker";
      binding = "<Super>d";
    };
    "org/gnome/settings-daemon/plugins/media-keys".custom-keybindings = [
      "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/walker/"
    ];
  };

  systemd.user.services.walker.Unit.X-Restart-Triggers = [
    "${config.xdg.configFile."walker/config.toml".source}"
  ];
}
