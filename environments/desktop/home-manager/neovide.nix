{
  config,
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.neovide ];

  programs.zsh.shellAliases.n = "neovide";
  programs.fish.shellAbbrs.n = "neovide";

  home.file.".config/neovide/config.toml".source =
    let
      toml = pkgs.formats.toml { };
    in
    toml.generate "config.toml" {
      font = {
        normal = [ "JetBrainsMono Nerd Font" ];
        size = 11.0;
      };
      fork = false;
      frame = if config.wayland.windowManager.hyprland.enable then "none" else "full";
      idle = true;
      maximied = false;
      no-multigrid = false;
      tabs = false;
      theme = "auto";
      title-hidden = true;
      vsync = true;
      wsl = false;
    };
}
