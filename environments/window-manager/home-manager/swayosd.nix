{ config, ... }:
{
  imports = [
    ./wallust.nix
  ];
  services.swayosd.enable = true;
  xdg.configFile."wallust/templates/swayosd.css".text = # css
    ''
      window#osd {
        border-radius: 999px;
        border: none;
        background-color: rgba({{cursor | rgb}}, 0.5);
      }
      window#osd #container {
        margin: 16px;
      }
      window#osd image,
      window#osd label {
        color: {{ foreground }};
      }
      window#osd progressbar:disabled,
      window#osd image:disabled {
        opacity: 0.5;
      }
      window#osd progressbar {
        min-height: 6px;
        border-radius: 999px;
        background: transparent;
        border: none;
      }
      window#osd trough {
        min-height: inherit;
        border-radius: inherit;
        border: none;
        background: rgba({{foreground | rgb}}, 0.5);
      }
      window#osd progress {
        min-height: inherit;
        border-radius: inherit;
        border: none;
        background-color: rgba({{foreground | rgb}}, 1);
      }
    '';
  programs.wallust.settings.templates.swayosd = {
    src = "swayosd.css";
    dst = "${config.xdg.configHome}/swayosd/style.css";
  };
  programs.wallust.postRun = ''
    systemctl --user restart swayosd.service
  '';
}
