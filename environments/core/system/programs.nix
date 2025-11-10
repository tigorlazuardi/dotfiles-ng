{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    lm_sensors
    yazi
    killall
    gnumake
    nurl
    lsof
    unzip
    openssl
    libcap
    fd
    dust
    ripgrep
    eza
  ];
}
