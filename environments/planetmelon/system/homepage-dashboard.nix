{
  config,
  pkgs,
  lib,
  ...
}:
let
  domain = "planetmelon.web.id";
  name = "planetmelon-homepage-dashboard";
  volume = "/var/lib/planetmelon/homepage-dashboard";
  settings = {
    title = "Planet Melon";
    description = "Planet Melon Services";
    # Source: https://old.reddit.com/r/NoMansSkyTheGame/comments/1igcetq/found_a_watermelon/
    background = {
      image = "https://i.redd.it/kfzvgz40ltge1.jpeg";
      blur = "sm";
    };
    favicon = "/images/fruit-watermelon.svg";
    layout = [
      {
        "Services" = {
          style = "row";
          columns = 2;
        };
      }
    ];
  };
  services = [
    {
      Services = [
        {
          Huly = {
            description = "Project Management and Tracker";
            href = "https://huly.planetmelon.web.id";
            icon = "/icons/huly.svg";
          };
        }

      ];
    }
  ];
  hulyIcon = pkgs.fetchurl {
    url = "https://docs.huly.io/_astro/huly-logo-bw.Dw8a0Ist_ZSPpJP.svg";
    hash = "";
  };
  favicon =
    # Source: https://pictogrammers.com/library/mdi/icon/fruit-watermelon/
    pkgs.writeText "fruit-watermelon.svg" # svg
      ''
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M16.4 16.4C19.8 13 19.8 7.5 16.4 4.2L4.2 16.4C7.5 19.8 13 19.8 16.4 16.4M16 7C16.6 7 17 7.4 17 8C17 8.6 16.6 9 16 9S15 8.6 15 8C15 7.4 15.4 7 16 7M16 11C16.6 11 17 11.4 17 12C17 12.6 16.6 13 16 13S15 12.6 15 12C15 11.4 15.4 11 16 11M12 11C12.6 11 13 11.4 13 12C13 12.6 12.6 13 12 13S11 12.6 11 12C11 11.4 11.4 11 12 11M12 15C12.6 15 13 15.4 13 16C13 16.6 12.6 17 12 17S11 16.6 11 16C11 15.4 11.4 15 12 15M8 17C7.4 17 7 16.6 7 16C7 15.4 7.4 15 8 15S9 15.4 9 16C9 16.6 8.6 17 8 17M18.6 18.6C14 23.2 6.6 23.2 2 18.6L3.4 17.2C7.2 21 13.3 21 17.1 17.2C20.9 13.4 20.9 7.3 17.1 3.5L18.6 2C23.1 6.6 23.1 14 18.6 18.6Z" /></svg>
      '';
in
{
  virtualisation.oci-containers.containers.${name} = {
    image = "ghcr.io/gethomepage/homepage:latest";
    ip = "10.88.10.254";
    httpPort = 3000;
    socketActivation.enable = true;
    volumes = [
      "${volume}/config:/app/config"
      "${volume}/images:/app/public/images"
      "${volume}/icons:/app/public/icons"
    ];
    environment = {
      HOMEPAGE_ALLOWED_HOSTS = domain;
    };
  };
  systemd.services."podman-${name}" =
    let
      format = pkgs.formats.yaml { };
      icons = {
        "fruit-watermelon.svg" = favicon;
        "huly.svg" = hulyIcon;
      };
      cpIcons = lib.concatMapAttrsStringSep "\n" (
        name: value: "cp ${value} ${volume}/images/${name}"
      ) icons;
      removes = lib.concatStringsSep " " (
        [
          "${volume}/config/settings.yaml"
          "${volume}/config/services.yaml"
        ]
        ++ lib.mapAttrsToList (name: _: "${volume}/icons/${name}") icons
      );
    in
    {
      preStart = ''
        mkdir -p ${volume}/{config,images,icons}
        rm -f ${removes} || true
        cp ${format.generate "settings.yaml" settings} ${volume}/config/settings.yaml
        cp ${format.generate "services.yaml" services} ${volume}/config/services.yaml
        ${cpIcons}
      '';
    };
}
