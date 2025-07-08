{
  networking.firewall.allowedTCPPorts = [ 22 ];
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      UseDns = false;
      X11Forwarding = false;
      PermitRootLogin = "no";
    };
  };
  services.fail2ban = {
    enable = true;
    maxretry = 5;
    ignoreIP = [
      "192.168.0.0/16"
      "2001:DB8::42"
    ];
    bantime = "24h";
    bantime-increment = {
      enable = true;
      multipliers = "1 2 4 8 16 32 64";
      maxtime = "168h";
      overalljails = true;
    };
  };
}
