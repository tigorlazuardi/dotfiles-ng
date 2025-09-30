{ config, pkgs, ... }:
{
  imports = [
    ../../window-manager/home-manager/wallust
  ];
  programs.wallust.settings.templates.dms = {
    src = "dms.json";
    dst = "${config.xdg.configHome}/DankMaterialShell/dms.json";
  };

  # TODO: These themes are ugly. For now wallust will not be enabled
  xdg.configFile."wallust/templates/dms.json".source = (pkgs.formats.json { }).generate "dms.json" {
    name = "Wallust";
    primary = "{{ color1 }}";
    primaryText = "{{ color1 | lighten(0.75) }}";
    primaryContainer = "{{ color1 | darken(0.25) }}";
    secondary = "{{ color2 }}";
    surface = "{{ color3 | darken(0.5) }}";
    surfaceText = "{{ color3 | lighten(0.5) }}";
    surfaceVariant = "{{ color4 | darken(0.5) }}";
    surfaceVariantText = "{{ color4 | lighten(0.5) }}";
    surfaceTint = "{{ cursor }}";
    background = "{{ background }}";
    backgroundText = "{{ foreground }}";
    outline = "{{ foreground }}";
    surfaceContainer = "{{ color5 | darken(0.5) }}";
    surfaceContainerHigh = "{{ color5 }}";
    surfaceContainerHighest = "{{ color5 | lighten(0.5) }}";
  };
}
