{ pkgs, ... }:
{
  home.packages = with pkgs.gnomeExtensions; [
    bangs-search
  ];

  # Configuration file are loaded by the bangs-search extension as per this line in the extension's source code:
  # https://github.com/suvanbanerjee/gnome-bangs/blob/48ef62e618cf65196f821db196fd3bb15435971c/prefs.js#L174
  #
  #
  # Gnome shell must be restarted for the configuration changes to take effect.
  home.file.".config/bangs.json".source = (pkgs.formats.json { }).generate "bangs.json" [
    {
      key = "!lib";
      url = "https://noogle.dev/q?term={query}";
    }
    {
      key = "!p";
      url = "https://search.nixos.org/packages?channel=unstable&query={query}";
    }
    {
      key = "!pkgs";
      url = "https://search.nixos.org/packages?channel=unstable&query={query}";
    }
    {
      key = "!pkg";
      url = "https://search.nixos.org/packages?channel=unstable&query={query}";
    }
    {
      key = "!o";
      url = "https://search.nixos.org/options?channel=unstable&query={query}";
    }
    {
      key = "!opt";
      url = "https://search.nixos.org/options?channel=unstable&query={query}";
    }
    {
      key = "!opts";
      url = "https://search.nixos.org/options?channel=unstable&query={query}";
    }
    {
      key = "!g";
      url = "https://www.google.com/search?q={query}";
    }
    {
      key = "!yt";
      url = "https://www.youtube.com/results?search_query={query}";
    }
  ];
  dconf.settings = {
    "org/gnome/shell".enabled-extensions = with pkgs.gnomeExtensions; [
      bangs-search.extensionUuid
    ];
  };
}
