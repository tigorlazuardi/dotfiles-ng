{
  services.caddy = {
    enable = true;
    globalConfig =
      # caddy
      ''
        encode
        email tigor.hutasuhut@gmail.com
      '';
  };
}
