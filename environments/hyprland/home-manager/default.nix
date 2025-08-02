{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.wayland.windowManager.hyprland =
    let
      inherit (lib) mkOption types;
    in
    {
      monitors = mkOption {
        type = with types; listOf str;
        description = ''List of monitors hyprland should manage'';
        example = ''[ ",preffered,auto,1" ]'';
        # We don't set default to force users to configure it.
      };
      workspaces = mkOption {
        type = with types; listOf str;
        description = ''List of workspaces hyprland should manage'';
        example = ''[ "1", "2", "3" ]'';
        # We don't set default to force users to configure it.
      };
    };
  config = {
    home.packages = with pkgs; [
      wl-clipboard
      font-manager
      vivaldi
      hyprland-qt-support
      hyprpolkitagent
    ];
    wayland.windowManager.hyprland = {
      enable = true;
      package = null; # Use NixOS package, not Home Manager package
      portalPackage = null; # Use NixOS package, not Home Manager package
      systemd.enable = false; # managed with uwsm
      settings = {
        general = {
          gaps_in = 2;
          gaps_out = 5;
          border_size = 3;
          layout = "dwindle";
        };
        master = {
          mfact = 0.75;
          new_status = "inherit";
        };
        dwindle = {
          pseudotile = true;
          preserve_split = true;
          force_split = 2;
        };
        gestures = {
          workspace_swipe = true;
          workspace_swipe_create_new = false;
        };
        monitors = config.wayland.windowManager.hyprland.monitors;
        workspaces = config.wayland.windowManager.hyprland.workspaces;
        "$mod" = "SUPER";
      };
    };
  };
}
