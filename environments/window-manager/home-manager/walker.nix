{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  tomlFormat = pkgs.formats.toml { };
  terminalLaunchPrefix =
    if config.programs.foot.server.enable then
      "${lib.meta.getExe' config.programs.foot.package "footclient"}"
    else
      "${lib.meta.getExe config.programs.foot.package}";
in
{
  imports = [
    inputs.walker.homeManagerModules.default
    ./wallust
  ];

  home.packages = with pkgs; [
    fd
  ];

  programs.walker = {
    enable = true;
    runAsService = true;

    config = {
      theme = "nixos";
      builtins.finder = {
        use_fd = true;
        preview_images = true;
      };
      builtins.applications.launch_prefix = "systemd-run --user ";
      builtins.runner.launch_prefix = "${terminalLaunchPrefix} ";
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
        {
          name = "Session";
          placeholder = "What do you want to do?";
          show_icon_when_single = true;
          show_sub_when_single = true;
          entries = [
            {
              label = "Logout";
              sub = "Logout from the current session";
              exec = "loginctl terminate-session $XDG_SESSION_ID";
              searchable = "logout exit stop quit loginctl";
              icon = "${pkgs.writeText "logout.svg" # svg
                ''
                  <svg viewBox="0 0 24 24" width="24" height="24" stroke="white" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1">
                    <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path>
                    <polyline points="16 17 21 12 16 7"></polyline>
                    <line x1="21" y1="12" x2="9" y2="12"></line>
                  </svg>
                ''
              }";
            }
            {
              label = "Lock Screen";
              sub = "Lock the screen";
              exec = "loginctl lock-session";
              searchable = "lock screen";
              icon = "${pkgs.writeText "lock.svg" # svg
                ''
                  <svg viewBox="0 0 24 24" width="24" height="24" stroke="white" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1">
                    <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
                    <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
                  </svg>
                ''
              }";
            }
            {
              label = "Suspend";
              sub = "Suspend the system";
              exec = "systemctl suspend";
              searchable = "suspend systemctl sleep systemd";
              icon = "${pkgs.fetchurl {
                url = "https://www.svgrepo.com/download/414477/sleep.svg";
                hash = "sha256-f6XGuP5A17R03kv5s63oy82Nnxtc9wEBsPdl/fr6I6w=";
              }}";
            }
            {
              label = "Suspend then Hibernate";
              sub = "Suspend the system and hibernate after a while";
              exec = "systemctl suspend-then-hibernate";
              searchable = "suspend hibernate systemctl sleep systemd";
              icon = "${pkgs.fetchurl {
                url = "https://www.svgrepo.com/download/147724/hibernate-button.svg";
                hash = "sha256-ovKw0MwEd6VJRf1efZDQRek0K0RBjIARo4fskl/I8po=";
              }}";
            }
            {
              label = "Hibernate";
              sub = "Hibernate the system immediately";
              exec = "systemctl hibernate";
              searchable = "hibernate systemctl systemd";
              icon = "${pkgs.fetchurl {
                url = "https://www.svgrepo.com/download/147724/hibernate-button.svg";
                hash = "sha256-ovKw0MwEd6VJRf1efZDQRek0K0RBjIARo4fskl/I8po=";
              }}";
            }
            {
              label = "Reboot";
              sub = "Reboot the system";
              exec = "systemctl reboot";
              searchable = "reboot systemctl restart";
              icon = "${pkgs.fetchurl {
                url = "https://www.svgrepo.com/download/529810/restart.svg";
                hash = "sha256-k0cdmEh+6VHoFRxnBbpJeIg2wsI/ZuxhO1544ro/FYo=";
              }}";
            }
            {
              label = "Power Off";
              sub = "Power off the system";
              exec = "systemctl poweroff";
              searchable = "power off shutdown systemctl systemd";
              icon = "${pkgs.fetchurl {
                url = "https://www.svgrepo.com/download/332492/poweroff.svg";
                hash = "sha256-iSmvcIsjyzwH+3sUtWQz0dNEDCYwM5tXg1Sl0KjEjNs=";
              }}";
            }
          ];
        }
        {
          name = "zoxide";
          placeholder = "Open recent directory in terminal or Neovide when Alt is held";
          prefix = "z ";
          parser = "json";
          src = pkgs.writers.writeJS "walker-zoxide.mjs" { } ''
            import { spawnSync } from "node:child_process";

            const result = spawnSync("zoxide", ["query", "--list", "--score"]);
            if (result.error) {
              console.error("Error running zoxide query --list --score:", result.error);
              process.exit(1);
            }
            const entries = [];
            for (const line of result.stdout.toString().split("\n")) {
              const l = line.trim();
              if (l === "") continue; // Skip empty lines
              const [score, path] = l.split(" ");
              const s = parseFloat(score);
              entries.push({
                label: path,
                sub: `Score: ''${score} • Hold Alt and press Enter to open in Neovide`,
                exec: `systemd-run --user ${terminalLaunchPrefix} --working-directory="''${path}" --title="Foot - ''${path}"`,
                exec_alt: `systemd-run --user --working-directory="''${path}" ${config.programs.neovide.package}/bin/neovide --no-fork`,
                score_final: isNaN(s) ? 0 : s,
                searchable: `zoxide ''${path}`,
                icon: "folder",
              });
            }
            console.log(JSON.stringify(entries));
          '';
        }
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

  xdg.configFile = with lib; {
    # We will read the default config from the package source and merge it with our custom config.
    "walker/themes/nixos.toml".source = tomlFormat.generate "walker-theme-config.toml" (
      recursiveUpdate
        (importTOML "${config.programs.walker.package.src}/internal/config/config.default.toml")
        {
          ui.window.box = {
            width = 1000;
            v_align = "center";
            scroll.list.max_height = 750;
            margins.top = 0;
          };
        }
    );
    "wallust/templates/walker.css".text = # css
      ''
        @define-color foreground rgba({{ foreground | rgb }}, 0.8);
        @define-color background rgba({{ background | rgb }}, 0.5);
        @define-color color1     {{ cursor }};

        #window,
        #box,
        #aiScroll,
        #aiList,
        #search,
        #password,
        #input,
        #prompt,
        #clear,
        #typeahead,
        #list,
        child,
        scrollbar,
        slider,
        #item,
        #text,
        #label,
        #bar,
        #sub,
        #activationlabel {
          all: unset;
        }

        #cfgerr {
          background: rgba(255, 0, 0, 0.4);
          margin-top: 20px;
          padding: 8px;
          font-size: 1.2em;
        }

        #window {
          color: @foreground;
        }

        #box {
          border-radius: 2px;
          background: @background;
          padding: 32px;
          border: 1px solid lighter(@background);
          box-shadow:
            0 19px 38px rgba(0, 0, 0, 0.3),
            0 15px 12px rgba(0, 0, 0, 0.22);
        }

        #search {
          box-shadow:
            0 1px 3px rgba(0, 0, 0, 0.1),
            0 1px 2px rgba(0, 0, 0, 0.22);
          background: lighter(@background);
          padding: 8px;
        }

        #prompt {
          margin-left: 4px;
          margin-right: 12px;
          color: @foreground;
          opacity: 0.2;
        }

        #clear {
          color: @foreground;
          opacity: 0.8;
        }

        #password,
        #input,
        #typeahead {
          border-radius: 2px;
        }

        #input {
          background: none;
        }

        #password {
        }

        #spinner {
          padding: 8px;
        }

        #typeahead {
          color: @foreground;
          opacity: 0.8;
        }

        #input placeholder {
          opacity: 0.5;
        }

        #list {
        }

        child {
          padding: 8px;
          border-radius: 2px;
        }

        child:selected,
        child:hover {
          background: alpha(@color1, 0.4);
        }

        #item {
        }

        #icon {
          margin-right: 8px;
        }

        #text {
        }

        #label {
          font-weight: 500;
        }

        #sub {
          opacity: 0.5;
          font-size: 0.8em;
        }

        #activationlabel {
        }

        #bar {
        }

        .barentry {
        }

        .activation #activationlabel {
        }

        .activation #text,
        .activation #icon,
        .activation #search {
          opacity: 0.5;
        }

        .aiItem {
          padding: 10px;
          border-radius: 2px;
          color: @foreground;
          background: @background;
        }

        .aiItem.user {
          padding-left: 0;
          padding-right: 0;
        }

        .aiItem.assistant {
          background: lighter(@background);
        }
      '';
  };

  programs.wallust = {
    postRun = ''
      systemctl --user restart walker.service
    '';
    settings.templates.walker = {
      src = "walker.css";
      dst = "${config.xdg.configHome}/walker/themes/nixos.css";
    };
  };
}
