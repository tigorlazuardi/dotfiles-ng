{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./audio.nix
    ./clipboard.nix
    ./css.nix
    ./nix_search.nix
    ./power-menu.nix
    ./systemd-user.nix
    ./zoxide.nix
  ];
  options.programs.sherlock.terminal =
    with lib;
    mkOption {
      type = types.str;
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
          home = "Home";
          priority = 5;
          spawn_focus = false;
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
