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
  services.nginx.virtualHosts =
    let
      proxyPass = "http://unix:${config.systemd.socketActivations.mailhog.address}";
    in
    {
      "mail.tigor.web.id" = {
        forceSSL = true;
        tinyauth.locations = [ "/" ];
        locations."/".proxyPass = proxyPass;
      };
      "mail.lan".locations."/".proxyPass = proxyPass;
    };
}
