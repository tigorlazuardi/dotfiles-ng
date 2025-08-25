{ config, pkgs, ... }:
let
  goPackages = with pkgs; [
    go
    wgo
    gotools
    gomodifytags
    gotests
    iferr
    gopls
    gofumpt
    impl
    golangci-lint
    delve
  ];
in
{
  programs.go.enable = true;
  home.packages = goPackages;
  home.file."go/bin" =
    let
      merged = pkgs.symlinkJoin {
        name = "home-go-bin";
        paths = goPackages;
      };
    in
    {
      source = "${merged}/bin";
      recursive = true;
    };
  home.sessionVariables.GOPATH = "${config.home.homeDirectory}/go";
}
