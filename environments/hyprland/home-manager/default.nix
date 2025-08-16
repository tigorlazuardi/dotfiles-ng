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
    ./avizo.nix
    # ./caelestia.nix
    ./hyprcursor.nix
    ./hypridle.nix
    ./hyprlock.nix
    ./hyprshot.nix
    ./kdeconnect.nix
    ./nemo.nix
    ./network.nix
    ./privacy.nix
    ./wpaperd.nix
    ./walker.nix
    # ./hyprpanel.nix
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
      workspace =
        let
          monitors = [
            "DP-1"
            "eDP-1"
          ];
          workspaceBinds = map (
            monitor:
            let
              index = builtins.genList (i: i + 1) 9; # Generate 1-9
              binds = map (i: "${toString i}, monitor:${monitor}") index;
            in
            binds
          ) monitors;
        in
        lib.flatten workspaceBinds
        ++ (map (monitor: "10, monitor:${monitor}") monitors)
        ++ [
          "11, monitor:DP-2" # Second monitor
          "12, monitor:DP-3" # Third monitor
        ]
        ++ [
          # Smart Gaps / No Gaps when only one window is open
          "w[tv1], gapsout:0, gapsin:0"
          "f[1], gapsout:0, gapsin:0"
        ];
      windowrulev2 = [
        "bordersize 0, floating:0, onworkspace:w[tv1]"
        "rounding 0, floating:0, onworkspace:w[tv1]"
        "bordersize 0, floating:0, onworkspace:f[1]"
        "rounding 0, floating:0, onworkspace:f[1]"
      ];
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
          "SUPER, TAB, workspace, previous" # Win+Tab to toggle between two workspaces
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
                "$mod,${i},workspace,${i}"
                "SUPER_SHIFT,${i},movetoworkspacesilent,${i}"
              ]
            ) index;
            workspaceGoto = lib.flatten workspacesTuples;
          in
          workspaceGoto
        )
        ++ [
          "SUPER, 0, workspace, 10" # Go to workspace 10
          "SUPER_SHIFT, 0, movetoworkspacesilent, 10" # Move window to workspace 10
        ];
      bindm = [
        "$mod, mouse:272, movewindow" # Move window with left mouse button + Super
        "$mod, mouse:273, resizewindow" # Resize window with right mouse button + Super
      ];
      binde = [
        "SUPER CTRL, H, resizeactive, -20 0"
        "SUPER CTRL, J, resizeactive, 0 20"
        "SUPER CTRL, K, resizeactive, 0 -20"
        "SUPER CTRL, L, resizeactive, 20 0"
      ];
    };
  };
}
