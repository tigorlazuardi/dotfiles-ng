{
  config,
  lib,
  pkgs,
  ...
}:
let
  homedir = config.home.homeDirectory;
  quickshellSource = "${homedir}/dotfiles/environments/window-manager/home-manager/quickshell";
  quickShellTarget = "${homedir}/.config/quickshell";
in
{
  home.packages = with pkgs; [
    quickshell
  ];
  # These options below are used to create a live configuration link to
  # this directory from-and-to quickshell's configuration.
  home.activation.symlinkQuickShell =
    lib.hm.dag.entryAfter [ "writeBoundary" ] # sh
      ''
        ln -sfn "${quickshellSource}" "${quickShellTarget}"
      '';
}
