{
  programs.nixvim = {
    autoCmd = [
      {
        callback.__raw = ''
          function()
            vim.hl.on_yank { higroup = "visual", timeout = 150 }
          end
        '';
        event = "TextYankPost";
      }
    ];
    plugins.yanky = {
      enable = true;
      settings.highlight = {
        timer = 150;
        on_yank = false;
      };
      lazyLoad.settings.keys = [
        {
          __unkeyed-1 = "y";
          __unkeyed-2 = "<Plug>(YankyYank)";
          mode = [
            "n"
            "x"
          ];
          desc = "Yank Text";
        }
        {
          __unkeyed-1 = "p";
          __unkeyed-2 = "<Plug>(YankyPutAfter)";
          mode = [
            "n"
            "x"
          ];
          desc = "Put Text After Cursor";
        }
        {
          __unkeyed-1 = "P";
          __unkeyed-2 = "<Plug>(YankyPutBefore)";
          mode = [
            "n"
            "x"
          ];
          desc = "Put Text Before Cursor";
        }
        {
          __unkeyed-1 = "gp";
          __unkeyed-2 = "<Plug>(YankyGPutAfter)";
          mode = [
            "n"
            "x"
          ];
          desc = "Put Text After Selection";
        }
        {
          __unkeyed-1 = "gP";
          __unkeyed-2 = "<Plug>(YankyGPutBefore)";
          mode = [
            "n"
            "x"
          ];
          desc = "Put Text Before Selection";
        }
        {
          __unkeyed-1 = "[y";
          __unkeyed-2 = "<Plug>(YankyCycleForward)";
          mode = [
            "n"
          ];
          desc = "Cycle Forward Through Yank History";
        }
        {
          __unkeyed-1 = "]y";
          __unkeyed-2 = "<Plug>(YankyCycleBackward)";
          mode = [
            "n"
          ];
          desc = "Cycle Backward Through Yank History";
        }
        {
          __unkeyed-1 = "[p";
          __unkeyed-2 = "<Plug>(YankyPutIndentAfterLinewise)";
          mode = [
            "n"
          ];
          desc = "Put Indented After Cursor (Linewise)";
        }
        {
          __unkeyed-1 = "]p";
          __unkeyed-2 = "<Plug>(YankyPutIndentBeforeLinewise)";
          mode = [
            "n"
          ];
          desc = "Put Indented Before Cursor (Linewise)";
        }
        {
          __unkeyed-1 = "[P";
          __unkeyed-2 = "<Plug>(YankyPutIndentAfterLinewise)";
          mode = [
            "n"
          ];
          desc = "Put Indented After Cursor (Linewise)";
        }
        {
          __unkeyed-1 = "]P";
          __unkeyed-2 = "<Plug>(YankyPutIndentBeforeLinewise)";
          mode = [
            "n"
          ];
          desc = "Put Indented Before Cursor (Linewise)";
        }
        {
          __unkeyed-1 = ">p";
          __unkeyed-2 = "<Plug>(YankyPutIndentAfterShiftRight)";
          mode = [
            "n"
          ];
          desc = "Put and Ident Right";
        }
        {
          __unkeyed-1 = "<p";
          __unkeyed-2 = "<Plug>(YankyPutIndentAfterShiftLeft)";
          mode = [
            "n"
          ];
          desc = "Put and Ident Left";
        }
        {
          __unkeyed-1 = ">P";
          __unkeyed-2 = "<Plug>(YankyPutIndentBeforeShiftRight)";
          mode = [
            "n"
          ];
          desc = "Put Before and Indent Right";
        }
        {
          __unkeyed-1 = "<P";
          __unkeyed-2 = "<Plug>(YankyPutIndentBeforeShiftLeft)";
          mode = [
            "n"
          ];
          desc = "Put Before and Indent Left";
        }
        {
          __unkeyed-1 = "=p";
          __unkeyed-2 = "<Plug>(YankyPutAfterFilter)";
          mode = [
            "n"
          ];
          desc = "Put After Applying a Filter";
        }
        {
          __unkeyed-1 = "=P";
          __unkeyed-2 = "<Plug>(YankyPutBeforeFilter)";
          mode = [
            "n"
          ];
          desc = "Put Before Applying a Filter";
        }
      ];
    };
  };
}
