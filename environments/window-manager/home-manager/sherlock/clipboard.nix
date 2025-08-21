{ pkgs, ... }:
{
  imports = [
    ../cliphist.nix
  ];
  home.packages = with pkgs; [
    # This provides the sherlock-clp command
    (rustPlatform.buildRustPackage rec {
      pname = "sherlock-clp";
      version = "234f9bbfe84ed20ff938bbdafc0c5481a68968e5";
      src = fetchFromGitHub {
        owner = "Skxxtz";
        repo = "sherlock-clipboard";
        rev = version;
        hash = "sha256-wrjlA/XUxgrn6gICB0ualZg3oX5YEd8HGchBq9/mnz0=";
      };
      cargoHash = "sha256-D2/L7vQkjEgawde9cZH45s0FSLluihqYSSwW5eLNMxM=";
    })
    (pkgs.writeShellScriptBin "sherlock-clipboard" ''
      set -euo pipefail
      sherlock-clp | sherlock | tr -d '\n' | cliphist decode | wl-copy
    '')
  ];
}
