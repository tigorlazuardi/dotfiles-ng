{ pkgs, ... }:
{
  users.users.tigor = {
    isNormalUser = true;
    description = "Tigor Hutasuhut";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.fish;
  };

  programs.fish.enable = true;

  nix.settings.trusted-users = [ "tigor" ];
}
