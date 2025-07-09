{
  config,
  lib,
  pkgs,
  ...
}:
let
  yamlType = (pkgs.formats.yaml { }).type;
in
{
  options =
    let
      inherit (lib) mkOption types mkEnableOption;
    in
    {
      services.homepage-dashboard = {
        extraIcons = mkOption {
          type = types.attrsOf types.path;
          default = { };
          description = ''
            Extra icons to included in the dashboard.

            The keys are the icon names to be referenced in the dashboard configuration,
            and the values are the paths to the icon files.'';
        };
        groups = mkOption {
          type = types.attrsOf (
            types.submodule (
              { name, ... }:
              {
                options = {
                  enable = mkOption {
                    type = types.bool;
                    default = true;
                  };
                  name = mkOption {
                    type = types.str;
                    default = name;
                  };
                  sortIndex = mkOption {
                    type = types.int;
                    default = 1000;
                  };
                  settings = mkOption {
                    type = yamlType;
                    default = { };
                  };
                  services = mkOption {
                    type = types.attrsOf (
                      types.submodule (
                        { name, ... }:
                        {
                          options = {
                            enable = mkOption {
                              type = types.bool;
                              default = true;
                            };
                            name = mkOption {
                              type = types.str;
                              default = name;
                            };
                            sortIndex = mkOption {
                              type = types.int;
                              default = 1000;
                            };
                            settings = mkOption {
                              type = yamlType;
                            };
                          };
                        }
                      )
                    );
                    default = { };
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
        filterAttrs
        ;
    in
    {
      sops.secrets."homepage/env".sopsFile = ../../../secrets/homepage.yaml;
      services.homepage-dashboard =
        let
          enabledGroupsSet = filterAttrs (
            name: group:
            group.enable
            && (
              let
                enabledServices = filterAttrs (_: conf: conf.enable) group.services;
              in
              enabledServices != { }
            )
          ) config.services.homepage-dashboard.groups;
          enabledGroupsList = attrValues enabledGroupsSet;
        in
        {
          enable = true;
          package = pkgs.homepage-dashboard.overrideAttrs {
            enableLocalIcons = true;
            postInstall =
              # sh
              ''
                mkdir -p $out/share/homepage/public/icons
                ${lib.concatMapAttrsStringSep "\n" (
                  name: value: "cp ${value} $out/share/homepage/public/icons/${name}"
                ) config.services.homepage-dashboard.extraIcons}
              '';
          };
          groups = {
            "Git and Personal Projects" = {
              settings = {
                style = "row";
                columns = 2;
              };
              sortIndex = 50; # Force top of the page.
            };
            Security = {
              settings = {
                style = "row";
                columns = 2;
              };
              sortIndex = 100;
            };
            Networking = {
              settings = {
                style = "row";
                columns = 3;
              };
              sortIndex = 250;
            };
            "Media Collectors" = {
              settings = {
                style = "row";
                columns = 4;
              };
              sortIndex = 950;
            };
            Media = {
              settings = {
                style = "row";
                columns = 3;
              };
              sortIndex = 900;
            };
            Monitoring = {
              settings = {
                style = "row";
                columns = 3;
              };
            };
          };
          settings = {
            title = "Tigor's Homeserver";
            description = "A front face for my personal server";
            startUrl = "https://tigor.web.id";
            useEqualHeights = true;
            layout =
              let
                sortedGroups = sort (l: r: l.sortIndex < r.sortIndex) enabledGroupsList;
                layout = map (group: {
                  ${group.name} = group.settings;
                }) sortedGroups;
              in
              layout;
          };
          services =
            let
              groupNames = attrNames enabledGroupsSet;
              services = map (
                groupName:
                let
                  entries = attrValues enabledGroupsSet.${groupName}.services;
                  sortedEntries = sort (l: r: l.sortIndex < r.sortIndex) entries;
                  final = map (entry: {
                    ${entry.name} = entry.settings;
                  }) sortedEntries;
                in
                {
                  ${groupName} = final;
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
      services.nginx.virtualHosts."tigor.web.id" = {
        forceSSL = true;
        locations."/".proxyPass =
          "http://unix:${config.services.anubis.instances.homepage-dashboard.settings.BIND}";
      };
    };
}
