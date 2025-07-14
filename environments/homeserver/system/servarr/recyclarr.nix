{ config, pkgs, ... }:
let
  settings = {
    radarr.movies = {
      base_url = "http://radarr:7878";
      api_key = config.sops.placeholder."servarr/api_keys/radarr";
      quality_definition.type = "movie";
      delete_old_custom_formats = true;
      custom_formats = [
        {
          trash_ids = [
            # x264 only. For 720p and 1080p releases.
            "2899d84dc9372de3408e6d8cc18e9666"
          ];
        }
      ];
    };
    sonarr = {
      tv = {
        base_url = "http://sonarr:8989";
        api_key = config.sops.placeholder."servarr/api_keys/sonarr";
        quality_definition.type = "series";
        delete_old_custom_formats = true;
        include = [
          { template = "sonarr-quality-definition-series"; }
          { template = "sonarr-v4-quality-profile-web-1080p"; }
          { template = "sonarr-v4-custom-formats-web-1080p"; }
        ];
        custom_formats = [
          {
            # This removes unwanted releases from being considered.
            trash_ids = [
              "32b367365729d530ca1c124a0b180c64" # Bad Dual Groups
              "82d40da2bc6923f41e14394075dd4b03" # No-RlsGroup
              "e1a997ddb54e3ecbfe06341ad323c458" # Obfuscated
              "06d66ab109d4d2eddb2794d21526d140" # Retags
              "1b3994c551cbb92a2c781af061f4ab44" # Scene
            ];
            assign_scores_to = [
              { name = "WEB-1080p"; }
            ];
          }
        ];
      };
      anime = {
        base_url = "http://sonarr-anime:8989";
        api_key = config.sops.placeholder."servarr/api_keys/sonarr-anime";
        quality_definition.type = "anime";
        delete_old_custom_formats = true;
        custom_formats = [
          # sudo podman run --rm ghcr.io/recyclarr/recyclarr list custom-formats sonarr
          {
            trash_ids = [
              # Anime Web Tier 02 (Top FanSubs)
              "19180499de5ef2b84b6ec59aae444696"
              # Anime Web Tier 03 (Official Subs)
              "c27f2ae6a4e82373b0f1da094e2489ad"
              # Anime web tier 04 (Official Subs)
              "4fd5528a3a8024e6b49f9c67053ea5f3"
            ];
          }
        ];
      };
    };
  };
  root = "/nas/mediaserver/servarr";
  configVolume = "${root}/recyclarr";
  inherit (config.users.users.servarr) uid;
  inherit (config.users.groups.servarr) gid;
in
{
  sops.secrets =
    let
      opts.sopsFile = ../../../../secrets/servarr.yaml;
    in
    {
      "servarr/api_keys/sonarr-anime" = opts;
      "servarr/api_keys/radarr" = opts;
    };
  sops.templates."servarr/recyclarr/recyclarr.yml" = {
    owner = config.users.users.servarr.name;
    file = (pkgs.formats.yaml { }).generate "recyclarr.yml" settings;
  };
  virtualisation.oci-containers.containers.recyclarr = {
    image = "ghcr.io/recyclarr/recyclarr:latest";
    environment = {
      TZ = "Asia/Jakarta";
    };
    ip = "10.88.3.6";
    volumes = [
      "${config.sops.templates."servarr/recyclarr/recyclarr.yml".path}:/config/recyclarr.yml"
      "${configVolume}:/config"
    ];
  };
  systemd.services.podman-recyclarr.preStart = ''
    mkdir -p ${configVolume}
    chown -R ${toString uid}:${toString gid} ${configVolume}
  '';
  system.activationScripts.recyclarr = ''
    mkdir -p ${configVolume} 
    chown ${toString uid}:${toString gid} ${configVolume}
  '';
}
