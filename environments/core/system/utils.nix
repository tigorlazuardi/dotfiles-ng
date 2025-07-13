{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "packfiles" # sh
      ''
        set -e
        export NIXPKGS_ALLOW_UNFREE=1
        build_path=$(nix build "nixpkgs#$1" --impure --no-link --print-out-paths)
        shift 1
        ${fd}/bin/fd --color=always --type f "$@" . $build_path
      ''
    )
    (writeShellScriptBin "build" # sh
      ''
        export NIXPKGS_ALLOW_UNFREE=1
        nix build --impure --expr "with import <nixpkgs> {}; callPackage $1 {}"
      ''
    )
  ];
}
