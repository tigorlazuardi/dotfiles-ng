{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkOption
    types
    mkEnableOption
    mapAttrs
    attrValues
    ;
  inherit (lib.lists) sort;
  yamlType = (pkgs.formats.yaml { }).type;
  groupType =
    { name, ... }:
    {
      name = mkOption {
        type = types.str;
        default = name;
      };
      index = mkOption {
        type = types.int;
        default = 0;
      };
      layout = {
        iconsOnly = mkEnableOption "icons only";
        style = mkOption {
          type = types.enum [
            "column"
            "row"
          ];
          default = "column";
        };
        columns = mkOption {
          type = types.ints.u16;
          default = 1;
        };
        header = mkOption {
          type = types.bool;
          default = true;
        };
        iconStyle = mkOption {
          type = types.enum [
            "theme"
            "gradient"
          ];
          default = "gradient";
        };
      };
      services = mkOption {
        type = types.listOf yamlType;
        default = [ ];
      };
    };
in
{
  options.services.homepage-dashboard.groups = mkOption {
    type = types.attrsOf (types.submodule groupType);
  };
  config = {
    services.homepage-dashboard = {
      package = pkgs.homepage-dashboard.overrideAttrs { enableLocalIcons = true; };
      settings = {
        title = "Tigor's Homeserver";
        description = "A front face for my personal server";
        startUrl = "https://tigor.web.id";
        layout =
          let
            entries = attrValues config.services.homepage-dashboard.groups;
            # Sort by index, if index is the same, sort by name.
            sorted = sort (
              left: right: if left.index == right.index then left.name < right.name else left.index < right.index
            ) entries;
            items = map (value: value.layout) sorted;
          in
          items;
      };
      services = mapAttrs (_: value: value.services) config.services.homepage-dashboard.groups;
    };
  };
}
