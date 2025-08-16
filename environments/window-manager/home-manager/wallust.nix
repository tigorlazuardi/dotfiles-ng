{ config, ... }:
{
  imports = [
    ./wpaperd.nix
  ];
  programs.wallust = {
    enable = true;
    settings = {
      backend = "fastresize";
      color_space = "lch";
      palette = "dark";
      templates = {
        css = {
          src = "colors.css";
          dst = "${config.xdg.dataHome}/wallpapers/colors.css";
        };
        gtk_css = {
          src = "gtk.css";
          dst = "${config.xdg.dataHome}/wallpapers/gtk.css";
        };
      };
    };
  };
  xdg.configFile."wallust/templates/colors.css".text = # css
    ''
      :root {
          --wallpaper: url("{{wallpaper}}");

          /* Special */
          --background: {{background}};
          --foreground: {{foreground}};
          --cursor: {{cursor}};

          /* Colors */
          --color0:  {{color0 }};
          --color1:  {{color1 }};
          --color2:  {{color2 }};
          --color3:  {{color3 }};
          --color4:  {{color4 }};
          --color5:  {{color5 }};
          --color6:  {{color6 }};
          --color7:  {{color7 }};
          --color8:  {{color8 }};
          --color9:  {{color9 }};
          --color10: {{color10}};
          --color11: {{color11}};
          --color12: {{color12}};
          --color13: {{color13}};
          --color14: {{color14}};
          --color15: {{color15}};
      }
    '';
  xdg.configFile."wallust/templates/gtk.css".text = # css
    ''
      @define-color cursor {{cursor}};
      @define-color background {{background}};
      @define-color foreground {{foreground}};
      @define-color color0  {{color0 }};
      @define-color color1  {{color1 }};
      @define-color color2  {{color2 }};
      @define-color color3  {{color3 }};
      @define-color color4  {{color4 }};
      @define-color color5  {{color5 }};
      @define-color color6  {{color6 }};
      @define-color color7  {{color7 }};
      @define-color color8  {{color8 }};
      @define-color color9  {{color9 }};
      @define-color color10 {{color10}};
      @define-color color11 {{color11}};
      @define-color color12 {{color12}};
      @define-color color13 {{color13}};
      @define-color color14 {{color14}};
      @define-color color15 {{color15}};
    '';
}
