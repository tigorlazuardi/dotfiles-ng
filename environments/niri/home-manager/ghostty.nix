{ config, lib, ... }:
{
  imports = [
    ../../desktop/home-manager/ghostty.nix
  ];

  programs.niri.settings.binds."Mod+Return" = {
    action.spawn = [
      "systemd-run"
      "--user"
      "${lib.meta.getExe config.programs.ghostty.package}"
    ];
    hotkey-overlay.title = "Open Ghostty Terminal";
  };
}
