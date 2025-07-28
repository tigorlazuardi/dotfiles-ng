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
  sessionStartPayload = {
    name = "default";
    start = true;
    config = {
      webhooks = [
        {
          url = "https://ntfy.tigor.web.id/whatsapp-raw";
          events = [
            "session.status"
          ];
          customHeaders = [
            {
              name = "Authorization";
              value = "Basic ${config.sops.placeholder."ntfy/client/user_base64"}";
            }
          ];
        }
      ];
    };
  };
in
{
  sops.templates."whatsapp/start.json".file =
    (pkgs.formats.json { }).generate "whatsapp-start.json"
      sessionStartPayload;
  # Docs: https://github.com/chrishubert/whatsapp-api/blob/master/docker-compose.yml
  virtualisation.oci-containers.containers.whatsapp = {
    # image = "docker.io/chrishubert/whatsapp-web-api:latest";
    image = "docker.io/devlikeapro/waha:latest";
    ip = "10.88.0.6";
    httpPort = 3000;
    environment = {
      # API Key Value: `whatsapp`
      WAHA_API_KEY = "sha512:a0fb52135d1ffd52c912bc05aad821e71d423bf831651f1ce71673a9af5c59dafe6b40046c80b40c32ab13054e5ed3c85368b3b640183ea901230704b1d84118";
    };
    volumes = [
      # We have to store the QR Code sessions
      "${volume}/sessions:/app/.sessions"
    ];
  };
  systemd.services.podman-whatsapp.preStart = ''
    mkdir -p ${volume}/sessions
  '';
  systemd.services.podman-whatsapp.serviceConfig.ExecStartPost = with pkgs; [
    # While the logs shows "Ready" early. It is infact NOT ready early.
    #
    # We have to wait for the server to actually opens the port
    # before we pass configurations to the server.
    "${waitport}/bin/waitport 600 ${ip} ${toString httpPort}"

    # This ensure every start, the api server will always use correct
    # settings every boot.
    (lib.meta.getExe (
      writeShellScriptBin "whatsapp-configure-session" ''
        set -x
        ${curl}/bin/curl -X PUT \
          -H "Content-Type: application/json" \
          -H "X-Api-Key: whatsapp" \
          --data @${config.sops.templates."whatsapp/start.json".path} \
          http://whatsapp.lan/api/sessions/default
      ''
    ))

    # We can start the session now so other services can push messages to my whatsapp.
    (lib.meta.getExe (
      writeShellScriptBin "whatsapp-session-start" ''
        set -x
        ${curl}/bin/curl \
          -H "Content-Type: application/json" \
          -H "X-Api-Key: whatsapp" \
          -X POST http://whatsapp.lan/api/sessions/default/start
      ''
    ))
  ];
  services.nginx.virtualHosts = {
    # For local access, e.g. by different services.
    "whatsapp.lan".locations."/".proxyPass = proxyPass;
    # For interactive access.
    "whatsapp.tigor.web.id" = {
      forceSSL = true;
      tinyauth.enable = true;
      locations."/".proxyPass = proxyPass;
    };
  };
}
