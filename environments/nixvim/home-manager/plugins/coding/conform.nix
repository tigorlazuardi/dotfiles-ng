{
  programs.nixvim = {
    plugins.conform-nvim = {
      enable = true;
      lazyLoad.settings.event = [
        "BufReadPost"
        "BufWritePost"
        "BufNewFile"
      ];
      luaConfig.post = # lua
        ''
          vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
          require("conform").formatters.injected = {
            options = {
              lang_to_ft = {
                bash = "sh",
              },
              lang_to_ext = {
                bash = "sh",
                c_sharp = "cs",
                elixir = "exs",
                javascript = "js",
                julia = "jl",
                latex = "tex",
                markdown = "md",
                python = "py",
                ruby = "rb",
                rust = "rs",
                teal = "tl",
                typescript = "ts",
              },
            },
          }
        '';
      settings = {
        format_on_save = {
          timeout_ms = 500;
          lsp_format = "fallback";
        };
      };
    };
  };
}
