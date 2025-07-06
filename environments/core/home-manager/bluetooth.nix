{ osConfig, lib, ... }:
{
  config = lib.mkIf osConfig.hardward.bluetooth.enable {
    programs.mpris-proxy.enable = true;
  };
}
