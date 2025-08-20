{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./systemd-user.nix
    ./zoxide.nix
  ];
  options.programs.sherlock.terminal =
    with lib;
    mkOption {
      type = types.string;
      default =
        if config.programs.foot.server.enable then
          "${config.programs.foot.package}/bin/footclient"
        else
          "${config.programs.foot.package}/bin/foot";
    };
  config = {
    programs.sherlock = {
      enable = true;
      package = inputs.sherlock.packages.${pkgs.system}.default;
      settings = {
        default_apps = {
          terminal =
            if (config.programs.foot.server.enable) then
              "${config.programs.foot.package}/bin/footclient"
            else
              "${config.programs.foot.package}/bin/foot";
          browser = "${config.programs.vivaldi.package}/bin/vivaldi %u";
        };
        behavior = {
          global_prefix = "systemd-run --user";
        };
      };
      systemd.enable = false; # sherlock daemon mode is not good enough for normal usage yet.
      launchers = [
        {
          name = "App Launcher";
          alias = "app";
          type = "app_launcher";
          args = { };
          priority = 3;
          home = "Home";
        }
        {
          name = "Kill Process";
          alias = "kill";
          type = "process";
          args = { };
          priority = 0;
        }
        {
          name = "Media Player";
          type = "audio_sink";
          async = true;
          home = "OnlyHome";
          priority = 5;
          args = { };
          actions =
            let
              playerctl = lib.meta.getExe pkgs.playerctl;
            in
            [
              {
                name = "Skip";
                icon = "media-skip-forward";
                method = "command";
                exec = "${playerctl} next";
                exit = true;
              }
              {
                name = "Previous";
                icon = "media-skip-backward";
                method = "command";
                exec = "${playerctl} previous";
                exit = true;
              }
              {
                name = "Play/Pause";
                icon = "media-play-pause";
                method = "command";
                exec = "${playerctl} play-pause";
                exit = true;
              }
            ];
        }
        {
          name = "Nix Lib Search";
          display_name = "Noogle";
          tag_start = "{keyword}";
          tag_end = "{keyword}";
          alias = "lib";
          type = "web_launcher";
          args = {
            search_engine = "https://noogle.dev/q?term={keyword}";
            icon = pkgs.fetchurl {
              url = "https://noogle.dev/favicon.png";
              hash = "sha256-5VjB+MeP1c25DQivVzZe77NRjKPkrJdYAd07Zm0nNVM=";
            };
          };
          priority = 1;
        }
        {
          name = "Nix Package Search";
          display_name = "Nixpkgs";
          tag_start = "{keyword}";
          tag_end = "{keyword}";
          alias = "p";
          type = "web_launcher";
          args = {
            search_engine = "https://search.nixos.org/packages?channel=unstable&query={keyword}";
            icon = pkgs.fetchurl {
              url = "https://search.nixos.org/images/nix-logo.png";
              hash = "sha256-4wRQyZ6CPOahELEvTY0h+7c6F1PPA6NvXGKBeDI/P8M=";
            };
          };
          priority = 1;
        }
        {
          name = "Nix Options Search";
          display_name = "Nix Options";
          tag_start = "{keyword}";
          tag_end = "{keyword}";
          alias = "o";
          type = "web_launcher";
          args = {
            search_engine = "https://search.nixos.org/options?channel=unstable&query={keyword}";
            icon = pkgs.fetchurl {
              url = "https://search.nixos.org/images/nix-logo.png";
              hash = "sha256-4wRQyZ6CPOahELEvTY0h+7c6F1PPA6NvXGKBeDI/P8M=";
            };
          };
          priority = 1;
        }
        {
          name = "Home Manager Search";
          display_name = "Home Manager";
          tag_start = "{keyword}";
          tag_end = "{keyword}";
          alias = "hm";
          type = "web_launcher";
          args = {
            search_engine = "https://home-manager-options.extranix.com/?release=master&query={keyword}";
            icon = pkgs.fetchurl {
              url = "https://search.nixos.org/images/nix-logo.png";
              hash = "sha256-4wRQyZ6CPOahELEvTY0h+7c6F1PPA6NvXGKBeDI/P8M=";
            };
          };
          priority = 1;
        }
        {
          name = "Web Search";
          display_name = "Google Search";
          tag_start = "{keyword}";
          tag_end = "{keyword}";
          alias = "g";
          type = "web_launcher";
          args = {
            search_engine = "google";
            icon = "google";
          };
          priority = 1;
        }
      ];
    };
  };
}
