{ pkgs, lib, ... }:
let
  lombokJar = builtins.fetchurl {
    url = "https://projectlombok.org/downloads/lombok-1.18.34.jar";
    sha256 = "sha256-wn1rKv9WJB0bB/y8xrGDcJ5rQyyA9zdO6x2CPobUuBo=";
  };
in
{
  programs.nixvim = {
    extraPlugins = [
      {
        plugin = pkgs.vimPlugins.nvim-jdtls;
        optional = true;
      }
    ];
    extraConfigLua = ''
      require("lz.n").load {
        "nvim-jdtls",
        event = "DeferredUIEnter",
        after = function()
          vim.api.nvim_create_autocmd("FileType", {
            pattern = "java",
            callback = function(ctx)
              local wk = require "which-key"
              wk.add {
                {
                  mode = "n",
                  buffer = args.buf,
                  { "<leader>cx", group = "extract" },
                  {
                    "<leader>cxv",
                    require("jdtls").extract_variable_all,
                    desc = "Extract Variable",
                  },
                  {
                    "<leader>cxc",
                    require("jdtls").extract_constant,
                    desc = "Extract Constant",
                  },
                  {
                    "<leader>cgs",
                    require("jdtls").super_implementation,
                    desc = "Goto Super",
                  },
                  {
                    "<leader>cgS",
                    require("jdtls.tests").goto_subjects,
                    desc = "Goto Subjects",
                  },
                  {
                    "<leader>co",
                    require("jdtls").organize_imports,
                    desc = "Organize Imports",
                  },
                },
              }
              wk.add {
                {
                  mode = "v",
                  buffer = args.buf,
                  { "<leader>cx", group = "extract" },
                  {
                    "<leader>cxm",
                    [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]],
                    desc = "Extract Method",
                  },
                  {
                    "<leader>cxv",
                    [[<ESC><CMD>lua require('jdtls').extract_variable_all(true)<CR>]],
                    desc = "Extract Variable",
                  },
                  {
                    "<leader>cxc",
                    [[<ESC><CMD>lua require('jdtls').extract_constant(true)<CR>]],
                    desc = "Extract Constant",
                  },
                },
              }
              local root = vim.fs.root(ctx.buf, { ".git", "mvnw", "gradlew" })
              local project_name = vim.fs.basename(root)
              local cmd = {
                [[${lib.getExe pkgs.jdt-language-server}]],
                "-configuration",
                vim.fn.stdpath "cache" .. "/jdtls/" .. project_name .. "/config",
                "-data",
                vim.fn.stdpath "cache" .. "/jdtls/" .. project_name .. "/workspace",
                [[--jvm-arg=-javaagent:${lombokJar}]],
              }
              require("jdtls").start_or_attach {
                cmd = cmd,
                root_dir = root,
                init_options = {
                  bundles = {
                    vim.fn.glob(
                      [[${pkgs.vscode-extensions.vscjava.vscode-java-debug}/share/vscode/extensions/vscjava.vscode-java-debug/server/com.microsoft.java.debug.plugin-*.jar]],
                      1
                    ),
                    vim.fn.glob(
                      [[${pkgs.vscode-extensions.vscjava.vscode-java-test}/share/vscode/extensions/vscjava.vscode-java-test/server/*.jar]],
                      1
                    ),
                    vim.fn.glob(
                      [[${pkgs.vscode-extensions.vscjava.vscode-maven}/share/vscode/extensions/vscjava.vscode-maven/jdtls.ext/*.jar]],
                      1
                    ),
                  },
                },
              }
            end,
          })
        end,
      }
    '';
  };
}
