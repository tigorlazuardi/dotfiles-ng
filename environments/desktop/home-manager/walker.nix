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
            pactl = lib.meta.getExe' pkgs.pulseaudio "pactl";
            jq = lib.meta.getExe pkgs.jq;
          in
          {
            name = "audio";
            placeholder = "Select Audio Output";
            show_icon_when_single = true;
            src = # sh
              "${pactl} -f json list sinks | ${jq} -r '.[].description'";
            cmd = # sh
              ''${lib.meta.getExe (
                pkgs.writeShellScriptBin "walker-audio" ''
                  selected=$(${pactl} -f json list sinks | ${jq} --arg result "$1" -r '.[] | select(.description == $result) | .name')
                  echo "$selected"
                  ${pactl} set-default-sink "$selected"
                ''
              )} "%RESULT%"'';
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
