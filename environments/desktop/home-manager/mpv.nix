{
  pkgs,
  ...
}:
{
  programs.mpv = {
    enable = true;
    config = {
      osc = "no";
    };
    scripts = with pkgs.mpvScripts; [
      mpris
      thumbnail
      sponsorblock
    ];
  };
}
