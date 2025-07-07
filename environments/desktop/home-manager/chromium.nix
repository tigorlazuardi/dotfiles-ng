{
  osConfig,
  lib,
  pkgs,
  ...
}:
{
  programs.chromium = {
    enable = true;
    extensions = [
      { id = "ddkjiahejlhfcafbddmgiahcphecmpfh"; } # Ublock Origin Lite
      { id = "nngceckbapebfimnlniiiahkandclblb"; } # Bitwarden

    ];
    nativeMessagingHosts = lib.optional osConfig.services.desktopManager.plasma6.enable pkgs.kdePackages.plasma-browser-integration;
  };
}
