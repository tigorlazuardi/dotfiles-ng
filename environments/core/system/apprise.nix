{
  config,
  pkgs,
  ...
}:
{
  sops.secrets =
    let
      opts = {
        sopsFile = ../../../secrets/apprise.yaml;
        mode = "444";
      };
    in
    {
      "apprise/discord/ytptube" = opts;
    };
  nixpkgs.overlays = [
    (
      self: super: with super; {
        apprise-discord-ytptube = writeShellScriptBin "apprise-discord-ytptube" ''
          set -e
          endpoint=$(cat ${config.sops.secrets."apprise/discord/ytptube".path})
          title="$1"
          message="$2"
          if [ -z "$message" ]; then
            message=$title
            title="YTPTube"
          fi
          ${apprise}/bin/apprise -t "$title" -b "$message" "$endpoint"
        '';
      }
    )
  ];
  environment.systemPackages = with pkgs; [
    apprise-discord-ytptube
  ];
}
