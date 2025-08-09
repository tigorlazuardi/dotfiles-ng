{ pkgs, ... }:
{
  home.file.".local/share/icons/rose-pine-hyprcursor".source = pkgs.fetchFromGitHub {
    owner = "ndom91";
    repo = "rose-pine-hyprcursor";
    rev = "4b02963d0baf0bee18725cf7c5762b3b3c1392f1";
    hash = "sha256-ouuA8LVBXzrbYwPW2vNjh7fC9H2UBud/1tUiIM5vPvM=";
  };

  wayland.windowManager.hyprland.settings.env = [
    "HYPRCURSOR_THEME,rose-pine-hyprcursor"
  ];
}
