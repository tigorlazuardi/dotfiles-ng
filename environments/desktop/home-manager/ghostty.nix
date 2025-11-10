{
  config,
  pkgs,
  lib,
  ...
}:
let

  cssFile =
    pkgs.writeText "ghostty.css"
      # css
      ''
        headerbar {
          margin: 0;
          padding: 0;
          min-height: 20px;
        }

        tabbar tabbox {
          margin: 0;
          padding: 0;
          min-height: 10px;
          background-color: #1a1a1a;
          font-family: monospace;
        }

        tabbar tabbox tab {
          margin: 0;
          padding: 0;
          color: #9ca3af;
          border-right: 1px solid #374151;
        }

        tabbar tabbox tab:selected {
          background-color: #2d2d2d;
          color: #ffffff;
        }

        tabbar tabbox tab label {
          font-size: 13px;
        }
      '';
in
{
  programs.ghostty = {
    enable = true;
    settings = {
      # font-family = "Hack Nerd Font Mono";
      font-family = "JetBrainsMono Nerd Font";
      font-size = 11;
      copy-on-select = "clipboard";
      linux-cgroup = "always";
      background-opacity = 0.9;
      unfocused-split-opacity = 0.875;
      clipboard-trim-trailing-spaces = true;
      clipboard-read = "allow";
      clipboard-write = "allow";
      app-notifications = "no-clipboard-copy";
      gtk-custom-css = "${cssFile}";
      keybind = [
        "ctrl+a>t=new_tab"
        "ctrl+a>enter=new_split:right"
        "ctrl+a>backspace=new_split:down"
        "ctrl+a>l=goto_split:right"
        "ctrl+a>k=goto_split:top"
        "ctrl+a>j=goto_split:bottom"
        "ctrl+a>h=goto_split:left"
        "ctrl+a>space=toggle_split_zoom"
        "ctrl+a>r=reload_config"
        "ctrl+a>w=close_surface"
        "ctrl+a>x=close_surface"
        "ctrl+a>1=goto_tab:1"
        "ctrl+a>2=goto_tab:2"
        "ctrl+a>3=goto_tab:3"
        "ctrl+a>4=goto_tab:4"
        "ctrl+a>5=goto_tab:5"
        "ctrl+a>6=goto_tab:6"
        "ctrl+a>7=goto_tab:7"
        "ctrl+a>8=goto_tab:8"
        "ctrl+a>9=goto_tab:9"
        "ctrl+a>0=goto_tab:10"
      ];
      shell-integration-features = "ssh-terminfo,ssh-env";
    };
  };
  dconf.settings = {
    "org/gnome/desktop/default-applications/terminal" = {
      exec = "${pkgs.ghostty}/bin/ghostty";
      exec-arg = "-e";
    };
    "org/gnome/shell".favorite-apps = [ "com.mitchellh.ghostty.desktop" ];
  };
  home.file =
    let
      background-filename = "ghostty-context-menu-background.nemo_action";
      dir-handler = "ghostty-context-menu-dir.nemo_action";
    in
    {
      # Schema: https://github.com/linuxmint/nemo/blob/master/files/usr/share/nemo/actions/sample.nemo_action
      ".local/share/nemo/actions/${background-filename}".source =
        (pkgs.formats.ini { }).generate background-filename
          {
            "Nemo Action" = {
              Name = "Open in Ghostty Terminal";
              Comment = "Open Ghostty on current directory";
              Exec = ''${lib.meta.getExe config.programs.ghostty.package} --working-directory="%P"'';
              Icon-Name = "com.mitchellh.ghostty";
              Selection = "none";
              Extensions = "none;";
            };
          };
      ".local/share/nemo/actions/${dir-handler}".source = (pkgs.formats.ini { }).generate dir-handler {
        "Nemo Action" = {
          Name = "Open in Ghostty Terminal";
          Comment = "Open Ghostty on selected directory";
          Exec = ''${lib.meta.getExe config.programs.ghostty.package} --working-directory="%F"'';
          Icon-Name = "com.mitchellh.ghostty";
          Selection = "single";
          Extensions = "dir";
        };
      };
    };
}
