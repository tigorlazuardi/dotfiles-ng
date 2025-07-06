{ user, ... }:
{
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3 --nogcroots"; # --nogcroots prevents direnv caches from being deleted
    clean.dates = "weekly";
    flake = "/home/${user.name}/dotfiles";
  };
}
