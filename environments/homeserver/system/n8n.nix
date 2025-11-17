{ config, ... }:
let
  domain = "n8n.tigor.web.id";
in
{
  services.n8n = {
    enable = true;
    environment = {
      WEBHOOK_URL = "https://${domain}";
      N8N_USER_MANAGEMENT_JWT_SECRET = "FUCK-SAML-LOGINS";
      N8N_USER_MANAGEMENT_JWT_DURATION_HOURS = toString (24 * 365 * 365 * 365);
      N8N_USER_MANAGEMENT_JWT_REFRESH_TIMEOUT_HOURS = toString (24 * 365 * 365 * 365);
      N8N_RUNNERS_ENABLED = "true";
      GENERIC_TIMEZONE = "Asia/Jakarta";
    };
  };
  services.nginx.virtualHosts."${domain}" = {
    forceSSL = true;
    tinyauth.enable = true;
    locations."/".proxyPass = "http://localhost:${config.services.n8n.environment.N8N_PORT}";
  };
}
