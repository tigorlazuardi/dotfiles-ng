{ user, pkgs, ... }:
{
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3 --nogcroots"; # --nogcroots prevents direnv caches from being deleted
    clean.dates = "weekly";
    flake = "/home/${user.name}/dotfiles";
  };
  security.sudo.extraRules = [
    {
      users = [ user.name ];
      commands = [
        {
          command = "/run/current-system/sw/bin/nh";
          options = [
            "SETENV"
            "NOPASSWD"
          ];
        }
      ];
    }
  ];

  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "update" ''
      nh os switch -- --accept-flake-config
      nix copy --to ssh://nix-ssh@ssh-serve.tigor.web.id --all || true
    '')
    (writeShellScriptBin "superupdate" ''
      nh os switch --update -- --accept-flake-config
      nix copy --to ssh://nix-ssh@ssh-serve.tigor.web.id --all || true
    '')
    (writeShellScriptBin "uptest" ''
      nh os test -- --accept-flake-config
      nix copy --to ssh://nix-ssh@ssh-serve.tigor.web.id --all || true
    '')
    (writeShellScriptBin "dry" ''
      sudo nixos-rebuild dry-activate --flake /home/${user.name}/dotfiles
    '')
  ];
}
