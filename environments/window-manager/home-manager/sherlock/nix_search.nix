{ pkgs, ... }:
{
  programs.sherlock.launchers = [
    {
      name = "Nix Lib Search";
      display_name = "Noogle";
      tag_start = "{keyword}";
      tag_end = "{keyword}";
      alias = "lib";
      type = "web_launcher";
      args = {
        search_engine = "https://noogle.dev/q?term={keyword}";
        icon = pkgs.fetchurl {
          url = "https://noogle.dev/favicon.png";
          hash = "sha256-5VjB+MeP1c25DQivVzZe77NRjKPkrJdYAd07Zm0nNVM=";
        };
      };
      priority = 0;
    }
    {
      name = "Nix Package Search";
      display_name = "Nixpkgs";
      tag_start = "{keyword}";
      tag_end = "{keyword}";
      alias = "p";
      type = "web_launcher";
      args = {
        search_engine = "https://search.nixos.org/packages?channel=unstable&query={keyword}";
        icon = pkgs.fetchurl {
          url = "https://search.nixos.org/images/nix-logo.png";
          hash = "sha256-4wRQyZ6CPOahELEvTY0h+7c6F1PPA6NvXGKBeDI/P8M=";
        };
      };
      priority = 0;
    }
    {
      name = "Nix Options Search";
      display_name = "Nix Options";
      tag_start = "{keyword}";
      tag_end = "{keyword}";
      alias = "o";
      type = "web_launcher";
      args = {
        search_engine = "https://search.nixos.org/options?channel=unstable&query={keyword}";
        icon = pkgs.fetchurl {
          url = "https://search.nixos.org/images/nix-logo.png";
          hash = "sha256-4wRQyZ6CPOahELEvTY0h+7c6F1PPA6NvXGKBeDI/P8M=";
        };
      };
      priority = 0;
    }
    {
      name = "Home Manager Search";
      display_name = "Home Manager";
      tag_start = "{keyword}";
      tag_end = "{keyword}";
      alias = "hm";
      type = "web_launcher";
      args = {
        search_engine = "https://home-manager-options.extranix.com/?release=master&query={keyword}";
        icon = pkgs.fetchurl {
          url = "https://search.nixos.org/images/nix-logo.png";
          hash = "sha256-4wRQyZ6CPOahELEvTY0h+7c6F1PPA6NvXGKBeDI/P8M=";
        };
      };
      priority = 0;
    }
  ];
}
