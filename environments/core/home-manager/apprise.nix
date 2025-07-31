{ config, pkgs, ... }:
{
  sops.secrets =
    let
      opts.sopsFile = ../../../secrets/apprise.yaml;
    in
    {
      "apprise/discord/ytptube" = opts;
    };
  home.packages = [
    (pkgs.writeShellScriptBin "apprise-discord-ytptube" ''
      endpoint=$(cat ${config.sops.secrets."apprise/discord/ytptube".path})
      ${pkgs.apprise}/bin/apprise "$@" "$endpoint"
    '')
  ];
}
