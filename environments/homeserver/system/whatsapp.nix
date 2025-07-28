{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (config.virtualisation.oci-containers.containers.whatsapp) ip httpPort;
  proxyPass = "http://${ip}:${toString httpPort}";
  volume = "/var/lib/whatsapp";
in
{
  sops.secrets."whatsapp/webhook_url".sopsFile = ../../../secrets/whatsapp.yaml;
  sops.templates."whatsapp/env".content = ''
    BASE_WEBHOOK_URL=${config.sops.placeholder."whatsapp/webhook_url"}
  '';
  # Docs: https://github.com/chrishubert/whatsapp-api/blob/master/docker-compose.yml
  virtualisation.oci-containers.containers.whatsapp = {
    image = "docker.io/chrishubert/whatsapp-web-api:latest";
    ip = "10.88.0.6";
    httpPort = 3000;
    environment = {
      # This service is blocked from unauthenticated access.
      API_KEY = "whatsapp";
      MAX_ATTACHMENT_SIZE = toString (5 * 1024 * 1024); # 5 MB
      # ALL CALLBACKS: auth_failure|authenticated|call|change_state|disconnected|group_join|group_leave|group_update|loading_screen|media_uploaded|message|message_ack|message_create|message_reaction|message_revoke_everyone|qr|ready|contact_changed
      DISABLED_CALLBACKS = "message_ack";
      ENABLE_SWAGGER_ENDPOINT = "TRUE";
      RECOVER_SESSIONS = "TRUE";
    };
    environmentFiles = [
      config.sops.templates."whatsapp/env".path
    ];
    volumes = [
      "${volume}/sessions:/usr/src/app/sessions"
    ];
  };
  systemd.services.podman-whatsapp.preStart = ''
    mkdir -p ${volume}/sessions
  '';
  systemd.services.podman-whatsapp.serviceConfig.ExecStartPost = [
    (with pkgs; "${waitport}/bin/waitport 600 ${ip} ${toString httpPort}")
    (
      with pkgs;
      (lib.meta.getExe (
        writeShellScriptBin "start-whatsapp-session" ''
          ${curl}/bin/curl --silent --show-error -H "X-Api-Key: whatsapp" http://whatsapp.lan/session/start/tigor
        ''
      ))
    )
  ];
  services.nginx.virtualHosts = {
    # For local access, e.g. by different services.
    "whatsapp.lan".locations."/".proxyPass = proxyPass;
    # For interactive access.
    "whatsapp.tigor.web.id" = {
      forceSSL = true;
      tinyauth.enable = true;
      locations."= /".extraConfig = # nginx
        ''
          return 301 /api-docs;
        '';
      locations."/".proxyPass = proxyPass;
    };
  };
}
