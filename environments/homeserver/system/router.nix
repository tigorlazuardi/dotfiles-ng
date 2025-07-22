{
  services.nginx.virtualHosts."router.tigor.web.id" = {
    forceSSL = true;
    tinyauth.enable = true;
    locations."/".proxyPass = "http://192.168.100.1:80";
  };
}
