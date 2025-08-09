{
  pkgs,
  lib,
  osConfig,
  config,
  ...
}:
{
  imports = [
    ./avizo.nix
    ./hyprcursor.nix
    ./hypridle.nix
    ./hyprlock.nix
    ./wpaperd.nix
    ./walker.nix

    ../../gnome/home-manager/nemo.nix
    ../../window-manager/home-manager/alacritty.nix
    ../../window-manager/home-manager/foot.nix
  ];
  home.packages = with pkgs; [
    wl-clipboard
    font-manager
    hyprland-qt-support
  ];
  services.hyprpolkitagent.enable = config.wayland.windowManager.hyprland.enable;
  wayland.windowManager.hyprland = {
    enable = osConfig.programs.hyprland.enable;
    package = null; # Use NixOS package, not Home Manager package
    portalPackage = null; # Use NixOS package, not Home Manager package
    systemd = {
      enable = true;
      variables = [ "--all" ];
    };
    settings = {
      "$mod" = "SUPER";
      general = {
        gaps_in = 0;
        gaps_out = 0;
        layout = "master";
        resize_on_border = true;
      };
      master = {
        mfact = 0.625;
      };
      gestures = {
        workspace_swipe = true;
        workspace_swipe_create_new = false;
      };
      bind =
        with lib;
        [
          "$mod, Q, killactive"
          "$mod, Return, exec, ${meta.getExe' config.programs.foot.package "footclient"}"
          "$mod, B, exec, ${meta.getExe config.programs.vivaldi.package}"
          "$mod, E, exec, ${meta.getExe' pkgs.nemo-with-extensions "nemo"}"
          "SUPER_SHIFT, Delete, exec, uwsm stop"
        ]
        ++ (
          let
            index = builtins.genList (i: i + 1) 9; # Generate 1-9
            workspacesTuples = map (
              index:
              let
                i = toString index;
              in
              [
                "$mod,${i},moveworkspacetomonitor,${i} current"
                "$mod,${i},workspace,${i}"
              ]
            ) index;
            workspaces = lib.flatten workspacesTuples;
          in
          workspaces
        );
      bindm = [
        "$mod, mouse:272, movewindow" # Move window with left mouse button + Super
        "$mod, mouse:273, resizewindow" # Resize window with right mouse button + Super
      ];
    };
  };
}
