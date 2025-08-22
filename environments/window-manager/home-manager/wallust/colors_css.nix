{ config, lib, ... }:
let
  vars = [
    "cursor"
    "background"
    "foreground"
    "color0"
    "color1"
    "color2"
    "color3"
    "color4"
    "color5"
    "color6"
    "color7"
    "color8"
    "color9"
    "color10"
    "color11"
    "color12"
    "color13"
    "color14"
    "color15"
  ];
  # string: int -> string
  # e.g.
  # padRight "Hello" 10 => "Hello     "
  padRight =
    str:
    with lib;
    let
      strLen = stringLength str;
    in
    if strLen >= 20 then
      str
    else
      (concatStrings (flatten [
        str
        (replicate (20 - strLen) " ")
      ]));
  defineColor =
    color: # css
    ''
      --${padRight "${color}_50:"} {{ ${color} | lighten(0.9) }};
      --${padRight "${color}_100:"} {{ ${color} | lighten(0.8) }};
      --${padRight "${color}_150:"} {{ ${color} | lighten(0.7) }};
      --${padRight "${color}_200:"} {{ ${color} | lighten(0.6) }};
      --${padRight "${color}_250:"} {{ ${color} | lighten(0.5) }};
      --${padRight "${color}_300:"} {{ ${color} | lighten(0.4) }};
      --${padRight "${color}_350:"} {{ ${color} | lighten(0.3) }};
      --${padRight "${color}_400:"} {{ ${color} | lighten(0.2) }};
      --${padRight "${color}_450:"} {{ ${color} | lighten(0.1) }};
      --${padRight "${color}_500:"} {{ ${color} }};
      --${padRight "${color}:"} {{ ${color} }};
      --${padRight "${color}_550:"} {{ ${color} | darken(0.1) }};
      --${padRight "${color}_600:"} {{ ${color} | darken(0.2) }};
      --${padRight "${color}_650:"} {{ ${color} | darken(0.3) }};
      --${padRight "${color}_700:"} {{ ${color} | darken(0.4) }};
      --${padRight "${color}_750:"} {{ ${color} | darken(0.5) }};
      --${padRight "${color}_800:"} {{ ${color} | darken(0.6) }};
      --${padRight "${color}_850:"} {{ ${color} | darken(0.7) }};
      --${padRight "${color}_900:"} {{ ${color} | darken(0.8) }};
      --${padRight "${color}_950:"} {{ ${color} | darken(0.9) }};
    '';
  texts = map defineColor vars;
  css = lib.concatStringsSep "\n" texts;
in
{
  xdg.configFile."wallust/templates/colors.css".text = # css
    ''
      :root {
        --${padRight "wallpaper:"} url("{{ wallpaper }}");

        ${css}
      }
    '';
  programs.wallust.settings.templates.css = {
    src = "colors.css";
    dst = "${config.xdg.dataHome}/wallpapers/colors.css";
  };
}
