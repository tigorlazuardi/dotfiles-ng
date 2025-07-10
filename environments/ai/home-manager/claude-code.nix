{ config, pkgs, ... }:
{
  sops.secrets."claude-code/settings.json" = {
    sopsFile = ../../../secrets/claude-code.json;
    key = "";
    format = "json";
    path = "${config.home.homeDirectory}/.claude/settings.json";
  };
  home.packages = with pkgs; [
    claude-code
  ];
}
