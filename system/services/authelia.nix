{ config, lib, ... }:
let
  vhostOptions =
    { config, ... }:
    {

      options = {
        authelia = {
          enable = lib.mkEnableOption "Enable authelia location";
          locations = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "List of locations to enable authelia authentication for.";
          };
          instance = lib.mkOption {
            type = lib.types.str;
            default = "main";
            description = "The authelia instance to use for authentication.";
          };
        };
      };
      config = lib.mkIf config.enableAuthelia {
        locations =
          {
            "/authelia".extraConfig =
              # nginx
              ''
                internal;
                proxy_pass http://127.0.0.1:9091/api/authz/auth-request;
                ## Headers
                ## The headers starting with X-* are required.
                proxy_set_header X-Original-Method $request_method;
                proxy_set_header X-Original-URL $scheme://$http_host$request_uri;
                proxy_set_header X-Forwarded-For $remote_addr;
                proxy_set_header Content-Length "";
                proxy_set_header Connection "";

                ## Basic Proxy Configuration
                proxy_pass_request_body off;
                proxy_next_upstream error timeout invalid_header http_500 http_502 http_503; # Timeout if the real server is dead
                proxy_redirect http:// $scheme://;
                proxy_http_version 1.1;
                proxy_cache_bypass $cookie_session;
                proxy_no_cache $cookie_session;
                proxy_buffers 4 32k;
                client_body_buffer_size 128k;


                ## Advanced Proxy Configuration
                send_timeout 5m;
                proxy_read_timeout 240;
                proxy_send_timeout 240;
                proxy_connect_timeout 240;
              '';
          }
          // builtins.listToAttrs (
            map (loc: {
              name = loc;
              value.extraConfig =
                #nginx
                ''
                  auth_request /authelia;

                  ## Save the upstream metadata response headers from Authelia to variables.
                  auth_request_set $user $upstream_http_remote_user;
                  auth_request_set $groups $upstream_http_remote_groups;
                  auth_request_set $name $upstream_http_remote_name;
                  auth_request_set $email $upstream_http_remote_email;

                  ## Inject the metadata response headers from the variables into the request made to the backend.
                  proxy_set_header Remote-User $user;
                  proxy_set_header Remote-Groups $groups;
                  proxy_set_header Remote-Email $email;
                  proxy_set_header Remote-Name $name;
                  ## Modern Method: Set the $redirection_url to the Location header of the response to the Authz endpoint.
                  auth_request_set $redirection_url $upstream_http_location;
                  ## Modern Method: When there is a 401 response code from the authz endpoint redirect to the $redirection_url.
                  error_page 401 =302 $redirection_url;            

                  proxy_read_timeout 2h;
                  proxy_send_timeout 2h;
                '';
            }) config.autheliaLocations
          );
      };
    };
in
{
  options.services.nginx.virtualHosts =
    let
      inherit (lib) mkOption types mkEnableOption;
    in
    mkOption {
      type = types.attrsOf (
        types.submodule {
          options.authelia = {
            enable = mkEnableOption "Enable authelia authentication for this virtual host";
            locations = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = "List of locations to enable authelia authentication for.";
            };
            instance = mkOption {
              type = types.str;
              default = "main";
              description = "The authelia instance to use for authentication.";
            };
          };
        }
      );
    };
  config =
    let
      inherit (lib) mapAttrs;
    in
    {
      services.authelia.instances = mapAttrs (name: value: { }) config.security.acme.domains;
    };
}
