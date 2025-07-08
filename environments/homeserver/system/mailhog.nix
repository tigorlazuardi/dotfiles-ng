{ config, ... }:
{
  services.mailhog = {
    enable = true;
    storage = "maildir";
  };
  systemd.socketActivations.mailhog = {
    host = "0.0.0.0";
    port = 8025;
  };
  services.caddy.virtualHosts = {
    "mail.tigor.web.id".extraConfig =
      # caddy
      ''
        import tinyauth_main
        reverse_proxy unix/${config.systemd.socketActivations.mailhog.address}
      '';
    "http://mail.local".extraConfig = ''
      reverse_proxy unix/${config.systemd.socketActivations.mailhog.address}
    '';
  };
}
