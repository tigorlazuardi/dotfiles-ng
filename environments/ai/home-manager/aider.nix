{ config, pkgs, ... }:
{
  sops.secrets."aider.conf.yml" = {
    sopsFile = ../../../secrets/aider.yaml;
    key = "";
    path = "${config.home.homeDirectory}/.aider.conf.yml";
  };
  home.packages = with pkgs; [
    aider-chat-full
  ];
}
