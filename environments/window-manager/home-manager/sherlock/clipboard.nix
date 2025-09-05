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
      selected=$(sherlock-clp | sherlock | tr -d '\n')
      echo "Selected entry: $selected" >&2
      content=$(echo -n "$selected" | cliphist decode)
      if [ $? -ne 0 ]; then
        echo "Failed to get clipboard content: $content" >&2
        exit 1
      fi
      if [ -z "$content" ]; then
        echo "No content found for the selected entry: $selected" >&2
        exit 1
      fi
      echo -n "$content" | wl-copy
    '')
  ];
}
