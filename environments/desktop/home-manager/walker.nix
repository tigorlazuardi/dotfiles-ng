{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  tomlFormat = pkgs.formats.toml { };
in
{
  imports = [
    inputs.walker.homeManagerModules.default
  ];

  home.packages = with pkgs; [
    fd
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
  };

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
        {
          name = "Session";
          placeholder = "What do you want to do?";
          show_icon_when_single = true;
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
