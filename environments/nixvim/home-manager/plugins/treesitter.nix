{ pkgs, inputs, ... }:
{
  # imports = [
  #   ./treesitter-diagnostic.nix
  # ];
  # smartindent settings are interfering with treesitter
  programs.nixvim.opts.smartindent = pkgs.lib.mkForce false;
  programs.nixvim.extraPlugins = [
    {
      plugin = pkgs.vimPlugins.nvim-treesitter-endwise;
    }
    {
      plugin = pkgs.vimPlugins.ultimate-autopair-nvim;
      optional = true;
    }
    {
      plugin = pkgs.vimUtils.buildVimPlugin {
        pname = "neotab.nvim";
        src = inputs.neotab-nvim;
        version = inputs.neotab-nvim.shortRev;
        doCheck = false;
        doInstallCheck = false;
      };
      optional = true;
    }
  ];
  programs.nixvim.extraConfigLua = ''
    vim.filetype.add {
      extension = {
        env = "env",
      },
      pattern = {
        [".*/secrets/.*.yaml"] = "secrets.yaml",
        ["/tmp/%d+/.*.yaml"] = "secrets.yaml",
      },
    }
    vim.treesitter.language.register("env", "sh")
    vim.treesitter.language.register("secrets.yaml", "yaml")
    require("lz.n").load {
      {
        "ultimate-autopair.nvim",
        event = "InsertEnter",
        after = function()
          local ua = require "ultimate-autopair"
          local opts = {
            fastwarp = {
              map = "<c-l>",
              rmap = "<c-h>",
              cmap = "<c-l>",
              rcmap = "<c-h",
              nocursormove = false,
            },
            close = {
              enable = true,
              map = "<c-j>",
              cmap = "<c-j>",
            },
            -- {
            --   {
            --     "=",
            --     ";",
            --     ft = { "nix" },
            --     cond = function(fn)
            --       return not fn.in_node({}, {
            --         "comment",
            --         "string_fragment",
            --       })
            --     end,
            --     multiline = false,
            --   },
            -- },
          }
          ua.setup(opts)
        end,
      },
      {
        "neotab.nvim",
        event = "InsertEnter",
        after = function()
          require("neotab").setup {
            tabkey = "",
            smart_puncuators = {
              enabled = true,
              semicolon = {
                enabled = true,
                ft = { "cs", "c", "cpp", "java", "nix", "rust" },
              },
            },
          }
          vim.keymap.set("i", "<tab>", function()
            if vim.snippet.active { direction = 1 } then
              vim.snippet.jump(1)
              return
            end
            require("neotab").tabout()
          end, {
            silent = true,
            desc = "Jump to next snippet / Accept Copilot Suggestion / Tabout / Tab",
          })
        end,
      },
    }
  '';
  programs.nixvim.plugins = {
    treesitter = {
      enable = true;
      package = pkgs.vimPlugins.nvim-treesitter;
      settings = {
        highlight.enable = true;
        indent.enable = true;
        incremental_selection = {
          enable = true;
          keymaps = {
            init_selection = "<C-space>";
            node_incremental = "<C-space>";
            scope_incremental = false;
            node_decremental = "<bs>";
          };
        };
      };
    };
    ts-autotag = {
      enable = true;
      package = pkgs.vimPlugins.nvim-ts-autotag;
      settings = {
        opts.enable_close_on_slash = true;
      };
      lazyLoad.settings.ft = [
        "html"
        "gohtml"
        "javascriptreact"
        "typescriptreact"
        "svelte"
        "vue"
        "tmpl"
        "astro"
        "markdown"
        "php"
        "twig"
        "blade"
        "xml"
      ];
    };
    # nvim-autopairs = {
    #   enable = true;
    #   lazyLoad.settings.ft = [ "InsertEnter" ];
    #   settings = {
    #     ignored_next_char = ''[=[[%%%'%[%\"%.%%$]]=]'';
    #   };
    # };
    ts-comments = {
      enable = true;
      settings = {
        opts.ignore_whitespace = true;
      };
    };
    treesitter-context = {
      enable = true;
      settings = {
        enable = true;
        max_lines = 1;
      };
      lazyLoad.settings.event = [
        "BufReadPost"
        "BufWritePost"
        "BufNewFile"
      ];
    };
    treesitter-textobjects = {
      enable = true;
      move = {
        enable = true;
        gotoNextStart = {
          "]f" = "@function.outer";
          "]c" = "@class.outer";
          "]a" = "@parameter.inner";
        };
        gotoNextEnd = {
          "]F" = "@function.outer";
          "]C" = "@class.outer";
          "]A" = "@parameter.inner";
        };
        gotoPreviousStart = {
          "[f" = "@function.outer";
          "[c" = "@class.outer";
          "[a" = "@parameter.inner";
        };
        gotoPreviousEnd = {
          "[F" = "@function.outer";
          "[C" = "@class.outer";
          "[A" = "@parameter.inner";
        };
      };
      select = {
        enable = true;
        lookahead = true;
        keymaps = {
          af = "@function.outer";
          "if" = "@function.inner";
          ac = "@class.outer";
          ic = "@class.inner";
        };
      };
    };
    ts-context-commentstring = {
      enable = true;
      extraOptions.enable_autocmd = false;
    };
    mini.modules.comment.options.custom_commentstring.__raw = ''
      function()
        return require("ts_context_commentstring.internal").calculate_commentstring() or vim.bo.commentstring
      end
    '';
  };
}
