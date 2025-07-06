{
  programs.nixvim.plugins.flash = {
    enable = true;
    lazyLoad.settings.keys = [
      {
        __unkeyed-1 = "s";
        __unkeyed-2.__raw = ''
          function() require("flash").jump() end
        '';
        mode = [
          "n"
          "x"
          "o"
        ];
        desc = "Flash";
      }
      {
        __unkeyed-1 = "S";
        __unkeyed-2.__raw = ''
          function() require("flash").treesitter() end
        '';
        mode = [
          "n"
          "x"
          "o"
        ];
        desc = "Flash Treesitter";
      }
      {
        __unkeyed-1 = "o";
        __unkeyed-2.__raw = ''
          function() require("flash").remote() end
        '';
        mode = [
          "o"
        ];
        desc = "Flash Remote";
      }
    ];
  };
}
