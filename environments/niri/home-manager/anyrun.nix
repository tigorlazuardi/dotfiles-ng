{
  inputs,
  config,
  pkgs,
  ...
}:
{
  imports = [
    (
      { modulesPath, ... }:
      {
        # Important! We disable home-manager's module to avoid option
        # definition collisions
        disabledModules = [ "${modulesPath}/programs/anyrun.nix" ];
      }
    )
    inputs.anyrun.homeManagerModules.default
  ];
  programs.niri.settings.binds."Mod+f".action.spawn = [ "anyrun" ];
  programs.anyrun = {
    enable = true;
    config = {
      x = {
        fraction = 0.5;
      };
      y = {
        fraction = 0.3;
      };
      width = {
        fraction = 0.3;
      };
      hideIcons = false;
      ignoreExclusiveZones = false;
      layer = "overlay";
      hidePluginInfo = false;
      closeOnClick = false;
      showResultsImmediately = true;
      maxEntries = null;

      plugins = [
        "${pkgs.anyrun}/lib/libniri_focus.so"
        "${pkgs.anyrun}/lib/libapplications.so"
        "${pkgs.anyrun}/lib/libnix_run.so"
        "${pkgs.anyrun}/lib/libwebsearch.so"
      ];
    };
    extraCss = # css
      ''
        @import url("file://${config.xdg.configHome}/gtk-4.0/dank-colors.css");

        window {
          background: transparent;
        }

        box.main {
          padding: 5px;
          margin: 10px;
          border-radius: 10px;
          border: 2px solid @theme_selected_bg_color;
          background-color: alpha(@theme_bg_color, 0.8);
          box-shadow: 0 0 5px black;
        }

        text {
          min-height: 30px;
          padding: 5px;
          border-radius: 5px;
        }

        .matches {
          background-color: rgba(0, 0, 0, 0);
          border-radius: 10px;
        }

        box.plugin:first-child {
          margin-top: 5px;
        }

        box.plugin.info {
          min-width: 200px;
        }

        list.plugin {
          background-color: rgba(0, 0, 0, 0);
        }

        label.match.description {
          font-size: 10px;
        }

        label.plugin.info {
          font-size: 14px;
        }

        .match {
          background: transparent;
        }

        .match:selected {
          border-left: 4px solid @theme_selected_bg_color;
          background: alpha(@theme_selected_bg_color, 0.8);
          animation: fade 0.1s linear;
        }

        @keyframes fade {
          0% {
            opacity: 0;
          }

          100% {
            opacity: 1;
          }
        }
      '';
    extraConfigFiles = {
      "applications.ron".text = # ron
        ''
          Config(
            preprocess_exec_script: Some("${pkgs.writeShellScript "anyrun-preprocsss" "systemd-run --user $@"}")
            terminal: Some(Terminal(
              command: "footclient",
              args: "{}",
            ))
          )
        '';
      "websearch.ron".text = # ron
        ''
          Config(
            prefix: "",
            engines: [
              Google,
              Custom(
                name: "Nix Packages",
                url: "search.nixos.org/packages?channel=unstable&query={}"
              ),
              Custom(
                name: "Nix Options",
                url: "search.nixos.org/options?channel=unstable&query={}"
              ),
              Custom(
                name: "Home Manager Options",
                url: "home-manager-options.extranix.com/?query={}&release=master"
              )
            ]
          )
        '';
    };
  };
}
