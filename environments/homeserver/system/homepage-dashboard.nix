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
                            config = mkOption {
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
        filter
        filterAttrs
        ;
    in
    {
      sops.secrets."homepage/env".sopsFile = ../../../secrets/homepage.yaml;
      services.homepage-dashboard =
        let
          allGroups = attrValues config.services.homepage-dashboard.groups;
          enabledGroups = filter (
            group:
            group.enable
            && (
              let
                enabledServices = filterAttrs (_: conf: conf.enable) group.services;
              in
              enabledServices != { }
            )
          ) allGroups;
        in
        {
          enable = true;
          package = pkgs.homepage-dashboard.overrideAttrs { enableLocalIcons = true; };
          groups = {
            "Git and Personal Projects" = {
              columns = 2;
              sortIndex = 50; # Force top of the page.
            };
            Security = {
              columns = 2;
              sortIndex = 100;
            };
            "Media Collectors" = {
              columns = 4;
              sortIndex = 950;
            };
            Media = {
              columns = 4;
              sortIndex = 900;
            };
          };
          settings = {
            title = "Tigor's Homeserver";
            description = "A front face for my personal server";
            startUrl = "https://tigor.web.id";
            layout =
              let
                sortedGroups = sort (l: r: l.sortIndex < r.sortIndex) enabledGroups;
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
              groupNames = attrNames enabledGroups;
              services = map (
                groupName:
                let
                  entries = enabledGroups.${groupName}.services;
                  sortedEntries = sort (l: r: l.sortIndex < r.sortIndex) entries;
                  final = map (entry: entry.config) sortedEntries;
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
      services.caddy.virtualHosts."tigor.web.id".extraConfig =
        #caddy
        ''
          reverse_proxy unix/${config.services.anubis.instances.homepage-dashboard.settings.TARGET}
        '';
    };
}
