{ osConfig, lib, ... }:
{
  config = lib.mkIf osConfig.hardware.bluetooth.enable {
    services.mpris-proxy.enable = true;
  };
}
