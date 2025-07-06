{ pkgs, ... }:
{
  programs.nixvim = {
    extraPlugins = [
      {
        plugin = pkgs.vimPlugins.vim-dadbod;
        optional = true;
      }
      {
        plugin = pkgs.vimPlugins.vim-dadbod-completion;
        optional = true;
      }
      {
        plugin = pkgs.vimPlugins.vim-dadbod-ui;
        optional = true;
      }
    ];
    extraConfigLua = ''
      require("lz.n").load {
        { "vim-dadbod", cmd = { "DB" } },
        {
          "vim-dadbod-ui",
          cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
          before = function()
            require("lz.n").trigger_load "vim-dadbod"
            vim.g.db_ui_auto_execute_table_helpers = 1
            vim.g.db_ui_use_nerd_fonts = 1
          end,
        },
        {
          "vim-dadbod-completion",
          ft = { "sql", "mysql", "plsql", "pgsql", "sqlite" },
        },
      }
    '';
    plugins.blink-cmp.settings.sources = {
      per_filetype.sql = [
        "snippets"
        "dadbod"
        "buffer"
      ];
      providers.dadbod = {
        name = "Dadbod";
        module = "vim_dadbod_completion.blink";
      };
    };
  };
}
