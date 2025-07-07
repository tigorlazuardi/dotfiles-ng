{
  osConfig,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) optional;
in
{
  programs.chromium = {
    enable = true;
    extensions =
      [
        { id = "ddkjiahejlhfcafbddmgiahcphecmpfh"; } # Ublock Origin Lite
        { id = "nngceckbapebfimnlniiiahkandclblb"; } # Bitwarden
        { id = "fhcgjolkccmbidfldomjliifgaodjagh"; } # Cookie Auto Delete
        {
          id = "jinjaccalgkegednnccohejagnlnfdag"; # Violent Monkey
          crxPath = pkgs.fetchurl {
            # Url gained from https://www.crx4chrome.com/crx/29673/ --> Downlaod CRX from chrome web store
            url = "https://clients2.googleusercontent.com/crx/blobs/Ad_brx2wJj8UC-IlzR5kT9m6FvqP8LywJRMJrrhHNo3U366505CKbJ_wrkdDZ6npZT1UAl5B8i2dGt0x3CGnTBtqYUBQJ7nd97hI09QNXCOHOXQtPt-Y188Y2V28ssS0nuwAxlKa5QFEjDz--oR8XXjiHHaGcaivMq4a/JINJACCALGKEGEDNNCCOHEJAGNLNFDAG_2_31_0_0.crx";
            hash = "sha256-MF7a3ynX+A8QNrU0VLQQYG+QioZwC7lSVECjGidej28=";
          };
          version = "2.31.0";
        }
        { id = "mnjggcdmjocbbbhaepdhchncahnbgone"; } # Sponsor Block Youtube
        {
          id = "oefkkgfcahbeccgckjgbnfclcmnjgidg"; # Real Debrid Extension
          crxPath = pkgs.fetchurl {
            # Url gained from https://www.crx4chrome.com/crx/68408/ --> Download Crx From Crx4Chrome
            url = "https://f6.crx4chrome.com/crx.php?i=oefkkgfcahbeccgckjgbnfclcmnjgidg&v=1.6.0&p=68408&token=5be770b6c5dc420c22cfe3742d66bf371751864033";
            hash = "sha256-kBS5DAkvUX2WWP2FEnQQ4HAumYkQLK2d0C9j4euy2ds=";
          };
          version = "1.6.0";
        }
      ]
      ++ optional osConfig.services.desktopManager.plasma6.enable {
        id = "cimiefiiaegbelhefglklhhakcgmhkai";
      } # KDE Plasma Browser Integration
    ;
    nativeMessagingHosts = lib.optional osConfig.services.desktopManager.plasma6.enable pkgs.kdePackages.plasma-browser-integration;
  };
}
