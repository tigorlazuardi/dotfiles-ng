{ osConfig, ... }:
{
  programs.zoxide = {
    enable = true;
    options = osConfig.programs.zoxide.flags;
  };
}
