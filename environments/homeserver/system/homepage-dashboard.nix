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
                  };
                  group = mkOption {
                    type = types.str;
                    description = "Group to which the service belongs. Required";
                  };
                  icon = mkOption {
                    type = types.nullOr types.str;
                    description = "Icon for the service. If null, no icon will be displayed.";
                  };
                  url = mkOption {
                    type = types.str;
                    description = "URL to the service.";
                  };
                };
              }
            )
          );
        };
      };
    };

}
