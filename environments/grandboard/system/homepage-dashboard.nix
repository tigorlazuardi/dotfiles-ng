{
  config,
  pkgs,
  lib,
  ...
}:
let
  namespace = "grandboard";
  domain = "${namespace}.web.id";
  name = "${namespace}-homepage-dashboard";
  volume = "/var/lib/${namespace}/homepage-dashboard";
  settings = {
    title = "Grand Board";
    description = "Grand Board Services";
    favicon = "/icons/chess-board.svg";
    layout = [
      {
        "Services" = {
          style = "row";
          columns = 1;
        };
      }
      { "Organization" = { }; }
    ];
  };
  services = [
    {
      Services = [
        {
          Huly = {
            description = "Project Management and Tracker";
            href = "https://huly.${namespace}.web.id";
            icon = "/icons/huly.svg";
          };
        }
        {
          Penpot = {
            description = "Figma Alternative Document Designing";
            href = "https://penpot.${namespace}.web.id";
            icon = "/icons/penpot.png";
          };
        }
      ];
    }
    {
      Organization = [
        {
          "Grand Board" = {
            description = "Grand Board Github Page";
            href = "https://github.com/Grand-Board";
            icon = "github.svg";
          };
        }
      ];
    }
  ];
  bookmarks = [ ];
  hulyIcon = pkgs.fetchurl {
    url = "https://docs.huly.io/_astro/huly-logo-bw.Dw8a0Ist_ZSPpJP.svg";
    hash = "sha256-RbM6aeMphp3UAR3RbswY6rfc9A4+Bt3RDpD5SqEmeUE=";
  };
  penpotIcon = pkgs.fetchurl {
    url = "https://avatars.githubusercontent.com/u/30179644?s=200&v=4";
    hash = "sha256-F26kOuiQeh8iivkb7wOvMhGsnbfoVZf4z+LzUssZ2rk=";
  };
  favicon =
    # Source: https://www.svgrepo.com/svg/351866/chess-board
    pkgs.writeText "chess-board.svg" # xml
      ''
        <svg xmlns="http://www.w3.org/2000/svg" fill="#000000" width="800px" height="800px" viewBox="0 0 512 512"><path d="M255.9.2h-64v64h64zM0 64.17v64h64v-64zM128 .2H64v64h64zm64 255.9v64h64v-64zM0 192.12v64h64v-64zM383.85.2h-64v64h64zm128 0h-64v64h64zM128 256.1H64v64h64zM511.8 448v-64h-64v64zm0-128v-64h-64v64zM383.85 512h64v-64h-64zm128-319.88v-64h-64v64zM128 512h64v-64h-64zM0 512h64v-64H0zm255.9 0h64v-64h-64zM0 320.07v64h64v-64zm319.88-191.92v-64h-64v64zm-64 128h64v-64h-64zm-64 128v64h64v-64zm128-64h64v-64h-64zm0-127.95h64v-64h-64zm0 191.93v64h64v-64zM64 384.05v64h64v-64zm128-255.9v-64h-64v64zm191.92 255.9h64v-64h-64zm-128-191.93v-64h-64v64zm128-127.95v64h64v-64zm-128 255.9v64h64v-64zm-64-127.95H128v64h64zm191.92 64h64v-64h-64zM128 128.15H64v64h64zm0 191.92v64h64v-64z"/></svg>
      '';
in
{
  virtualisation.oci-containers.containers.${name} = {
    image = "ghcr.io/gethomepage/homepage:latest";
    ip = "10.88.11.254";
    httpPort = 3000;
    socketActivation.enable = true;
    volumes = [
      "${volume}/config:/app/config"
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
        "chess-board.svg" = favicon;
        "huly.svg" = hulyIcon;
        "penpot.png" = penpotIcon;
      };
      cpIcons = lib.concatMapAttrsStringSep "\n" (
        name: value: "cp ${value} ${volume}/icons/${name} || true"
      ) icons;
      removes = lib.concatStringsSep " " [
        "${volume}/config/settings.yaml"
        "${volume}/config/services.yaml"
        "${volume}/config/bookmarks.yaml"
      ];
    in
    {
      preStart = ''
        mkdir -p ${volume}/{config,icons}
        rm -f ${removes} || true
        cp ${format.generate "settings.yaml" settings} ${volume}/config/settings.yaml
        cp ${format.generate "services.yaml" services} ${volume}/config/services.yaml
        cp ${format.generate "bookmarks.yaml" bookmarks} ${volume}/config/bookmarks.yaml
        ${cpIcons}
        chown -R 0:0 ${volume}
        chmod -R 700 ${volume}
      '';
    };
  services.anubis.instances.${name}.settings.TARGET = "unix://${
    config.systemd.socketActivations."podman-${name}".address
  }";
  services.nginx.virtualHosts."${domain}" = {
    forceSSL = true;
    useACMEHost = "${namespace}.web.id";
    locations."/".proxyPass = "http://unix:${config.services.anubis.instances.${name}.settings.BIND}";
  };
}
