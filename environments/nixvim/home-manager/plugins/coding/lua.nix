{ pkgs, ... }:
{
  programs.nixvim = {
    extraPackages = with pkgs; [
      lua-language-server
      stylua
    ];

    plugins = {
      lazydev = {
        enable = true;
        lazyLoad.settings.ft = [ "lua" ];
      };
      conform-nvim.settings.formatters_by_ft.lua = [ "stylua" ];
      blink-cmp.settings.sources = {
        default = [ "lazydev" ];
        providers = {
          lazydev = {
            name = "LazyDev";
            module = "lazydev.integrations.blink";
            # make lazydev completions top priority (see `:h blink.cmp`)
            score_offset = 100;
          };
        };
      };
    };
  };
}
