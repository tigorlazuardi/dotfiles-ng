{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.sherlock = {
    enable = true;
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
        use_xdg_data_dir_icons = true;
        global_prefix = "systemd-run --user ";
      };
    };
    systemd.enable = true;
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
        priority = 1;
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
        alias = "g";
        type = "web_launcher";
        args = {
          search_engine = "google";
          icon = "google";
        };
        priority = 100;
      }
    ];
  };
}
