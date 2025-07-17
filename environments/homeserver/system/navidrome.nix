{ config, ... }:
let
  domain = "music.tigor.web.id";
in
{
  # For maximum compatibility regarding OS file permissions,
  # user must be member of "navidrome" group, and "navidrome" user must be
  # member of user's group.
  #
  # e.g.
  #
  # users.users.${username}.extraGroups = [ "navidrome" ];
  # users.users.navidrome.extraGroups = [ username ];

  services.navidrome = {
    enable = true;
    settings = {
      Address = "127.0.0.1";
      MusicFolder = "/nas/Syncthing/Sync/Music";
      SessionTimeout = "8760h"; # 1 Year. Authentication will be handled by TinyAuth.
      ReverseProxyWhitelist = "0.0.0.0/0,::/0"; # This service is only accessible via reverse proxy.
    };
  };
  systemd.socketActivations.navidrome =
    let
      inherit (config.services.navidrome.settings) Address Port;
    in
    {
      host = Address;
      port = Port;
      idleTimeout = "30s";
    };
  services.nginx.virtualHosts = {
    "${domain}" = {
      forceSSL = true;
      tinyauth.locations = [ "/" ];
      locations =
        let
          inherit (config.systemd.socketActivations.navidrome) address;
        in
        {
          "/".proxyPass = "http://unix:${address}";
          # "/api".proxyPass = "http://unix:${address}";
          "/rest".proxyPass = "http://unix:${address}"; # Subsonic API endpoint. Let Navidrome handle this.
        };
    };
  };
  services.homepage-dashboard.groups.Media.services.Navidrome.settings = {
    description = "Self-hosted music server and streaming service";
    href = "https://${domain}";
    icon = "navidrome.svg";
    widget = {
      type = "navidrome";
      url = "https://${domain}";
      user = "{{HOMEPAGE_VAR_NAVIDROME_USERNAME}}";
      token = "{{HOMEPAGE_VAR_NAVIDROME_TOKEN}}";
      salt = "{{HOMEPAGE_VAR_NAVIDROME_SALT}}";
    };
  };
}
