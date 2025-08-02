{ config, inputs, ... }:
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
          name = "YouTube";
          prefix = "yt ";
          url = "https://www.youtube.com/results?search_query=%TERM%";
        }
      ];
      terimnal = "${config.programs.ghostty.package}/bin/ghostty";
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
    };
  };

  dconf.settings = {
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      name = "Walker";
      command = "walker";
      binding = "<Super>d";
    };
    "org/gnome/settings-daemon/plugins/media-keys".custom-keybindings = [
      "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
    ];
  };
}
