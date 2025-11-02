{
  pkgs,
  user,
  lib,
  ...
}:
{
  services.printing = {
    enable = true;
    drivers = [ pkgs.brlaser ]; # Brother Laser Printer
    openFirewall = true;
    defaultShared = true;
    listenAddresses = [ "*:631" ];
    allowFrom = [ "all" ];
    browsing = true;
    webInterface = true;
    extraConf = lib.mkForce ''
      DefaultAuthType None
      DefaultEncryption Never

      <Location />
        Order allow,deny
        Allow all
      </Location>

      <Location /admin>
        Order allow,deny
        Allow all
      </Location>

      <Location /admin/conf>
        Order allow,deny
        Allow all
      </Location>
    '';
  };
  services.avahi.enable = true;
  hardware.sane = {
    enable = true;
    brscan4.enable = true; # Brother Scanner
    extraBackends = with pkgs; [ sane-airscan ];
    netDevices = {
      home = {
        model = "DCP-L2540DW";
        host = "192.168.100.240";
      };
    };
  };
  users.users.${user.name}.extraGroups = [
    "scanner" # For sane scanner access
    "lp" # For printer access
  ];
  services.udev.packages = [ pkgs.sane-airscan ];
  services.ipp-usb.enable = true;
  services.nginx.virtualHosts."cups.lan".locations."/".proxyPass = "http://localhost:631";
}
