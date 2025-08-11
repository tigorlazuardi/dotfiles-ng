{
  pkgs,
  lib,
  osConfig,
  config,
  ...
}:
{
  imports = [
    ./audio.nix
    # ./avizo.nix
    ./caelestia.nix
    ./hyprcursor.nix
    ./hypridle.nix
    ./hyprlock.nix
    ./hyprshot.nix
    ./network.nix
    ./wpaperd.nix
    ./walker.nix
    # ./hyprpanel.nix

    ../../gnome/home-manager/nemo.nix
    ../../window-manager/home-manager/alacritty.nix
    ../../window-manager/home-manager/foot.nix
    ../../window-manager/home-manager/quickshell
    ../../window-manager/home-manager/waybar
  ];
  home.packages = with pkgs; [
    wl-clipboard
    font-manager
    hyprland-qt-support
    brightnessctl
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
      monitor = [
        ", highres@highrr, auto, 1"
      ];
      general = {
        gaps_in = lib.mkDefault 0;
        gaps_out = lib.mkDefault 0;
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
      misc = {
        vrr = 0;
        focus_on_activate = true;
        enable_swallow = true;
      };
      bind =
        with lib;
        [
          "$mod, Q, killactive"
          "$mod, Return, exec, ${meta.getExe' config.programs.foot.package "footclient"}"
          "$mod, B, exec, ${meta.getExe config.programs.vivaldi.package}"
          "$mod, E, exec, ${meta.getExe' pkgs.nemo-with-extensions "nemo"}"
          "SUPER_SHIFT, Delete, exec, uwsm stop"
          "SUPER, space, fullscreen, 0"
          "SUPER, H, movefocus, l"
          "SUPER, J, movefocus, d"
          "SUPER, K, movefocus, u"
          "SUPER, L, movefocus, r"
          "SHIFT_SUPER, H, swapwindow, l"
          "SHIFT_SUPER, J, swapwindow, d"
          "SHIFT_SUPER, K, swapwindow, u"
          "SHIFT_SUPER, L, swapwindow, r"
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
                "SUPER_SHIFT,${i},movetoworkspacesilent,${i}"
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
