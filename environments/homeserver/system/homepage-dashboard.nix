{
  config,
  lib,
  pkgs,
  ...
}:
let
  yamlType = (pkgs.formats.yaml { }.type);
in
{
  options =
    let
      inherit (lib) mkOption types mkEnableOption;
    in
    {
      services.homepage-dashboard = {
        groups = mkOption {
          type = types.attrsOf (
            types.submodule (
              { name, ... }:
              {
                options = {
                  name = mkOption {
                    type = types.str;
                    default = name;
                  };
                  sortIndex = mkOption {
                    type = types.int;
                    default = 0;
                  };
                  iconsOnly = mkEnableOption "enable icons-only display for the group";
                  style = mkOption {
                    type = types.enum [
                      "row"
                      "column"
                    ];
                    default = "row";
                  };
                  columns = mkOption {
                    type = types.int;
                    default = 1;
                    description = "Number of columns to display in the group.";
                  };
                  header = mkOption {
                    type = types.bool;
                    default = true;
                  };
                  icon = mkOption {
                    type = types.nullOr types.str;
                    description = "Icon for the group. If null, no icon will be displayed.";
                  };
                };
              }
            )
          );
        };
        services = mkOption {
          type = types.attrsOf (
            types.submodule (
              { name, ... }:
              {
                options = {
                  name = mkOption {
                    type = types.str;
                    default = name;
                  };
                  sortIndex = mkOption {
                    type = types.int;
                    default = 0;
                    description = "Sort index for the service inside the group. Lower values appear first.";
                  };
                  group = mkOption {
                    type = types.str;
                    description = "Group to which the service belongs. Required";
                  };
                  icon = mkOption {
                    type = types.nullOr types.str;
                    description = "Icon for the service. If null, no icon will be displayed.";
                  };
                  href = mkOption {
                    type = types.str;
                    description = "URL to the service.";
                  };
                  description = mkOption {
                    type = types.str;
                    default = "";
                    description = "Description of the service.";
                  };
                  widget = mkOption {
                    type = yamlType;
                    default = null;
                    description = "Widget configuration for the service. If null, no widget will be displayed.";
                  };
                };
              }
            )
          );
        };
      };
    };
  config =
    let
      inherit (lib)
        attrValues
        sort
        attrNames
        filter
        ;
    in
    {
      sops.secrets."homepage/env".sopsFile = ../../../secrets/homepage.yaml;
      services.homepage-dashboard = {
        enable = true;
        settings = {
          title = "Tigor's Homeserver";
          description = "A front face for my personal server";
          startUrl = "https://tigor.web.id";
          layout =
            let
              groupValues = attrValues config.services.homepage-dashboard.groups;
              sortedGroups = sort (
                l: r: if l.sortIndex == r.sortIndex then l.name < r.name else l.sortIndex < r.sortIndex
              ) groupValues;
              layout = map (group: {
                inherit (group)
                  iconsOnly
                  style
                  columns
                  header
                  icon
                  ;
              }) sortedGroups;
            in
            layout;
        };
        services =
          let
            groupNames = attrNames config.services.homepage-dashboard.groups;
            serviceValues = attrValues config.services.homepage-dashboard.services;
            services = map (
              group:
              let
                services = filter (service: service.group == group) serviceValues;
                sortedServices = sort (
                  l: r: if l.sortIndex == r.sortIndex then l.name < r.name else l.sortIndex < r.sortIndex
                ) services;
              in
              {
                ${group} = sortedServices;
              }
            ) groupNames;
          in
          services;
        widgets = [
          {
            greeting = {
              text_size = "2xl";
              text = "Tigor's Homeserver";
            };
          }
          {
            search = {
              provider = "google";
              focus = true;
              showSearchSuggestions = true;
              target = "_blank";
            };
          }
          {
            resources = {
              cpu = true;
              memory = true;
              cputemp = true;
              uptime = true;
              units = "metric";
              network = true;
              disk = [
                "/"
                "/nas"
                "/wolf"
              ];
            };
          }
        ];
        allowedHosts = "tigor.web.id";
        environmentFile = config.sops.secrets."homepage/env".path;
      };
      systemd.socketActivations.homepage-dashboard = {
        host = "0.0.0.0";
        port = config.services.homepage-dashboard.listenPort;
        idleTimeout = "10s";
      };
      services.anubis.instances.homepage-dashboard.settings.TARGET =
        "unix://${config.systemd.socketActivations.homepage-dashboard.address}";
      services.caddy.virtualHosts."tigor.web.id".extraConfig =
        #caddy
        ''
          reverse_proxy unix/${config.services.anubis.instances.homepage-dashboard.settings.TARGET}
        '';
    };
}
