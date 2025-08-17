{ config, lib, ... }:
let
  footBinary =
    if config.programs.foot.server.enable then
      lib.meta.getExe' config.programs.foot.package "footclient"
    else
      lib.meta.getExe config.programs.foot.package;
in
{
  programs.nixvim.extraConfigLua = ''
    if vim.g.neovide then
      local font = "JetBrainsMono Nerd Font"

      local font_size = vim.o.lines < 60 and 11 or 12

      vim.o.guifont = font .. ":h" .. font_size
      vim.g.neovide_opacity = 0.7
      vim.g.transparency = 0.8
      vim.g.neovide_window_blurred = true

      vim.keymap.set("n", "<c-->", function()
        font_size = font_size - 1
        vim.o.guifont = font .. ":h" .. font_size
        vim.notify("Font Set: " .. font .. ":h" .. font_size)
      end, { desc = "Decrease font size" })

      vim.keymap.set("n", "<c-=>", function()
        font_size = font_size + 1
        vim.o.guifont = font .. ":h" .. font_size
        vim.notify("Font Set: " .. font .. ":h" .. font_size)
      end, { desc = "Increase font size" })

      ${lib.optionalString config.programs.foot.enable # lua
        ''
          vim.keymap.set({ "n" }, "<F5>", function()
            local cwd = vim.fn.getcwd()
            local title = ([[Neovide - Foot - %s]]):format(cwd)
            local app_id = ([[neovide-foot-%s]]):format(cwd:gsub("/", "-"))
            vim.system({
              "${footBinary}",
              "--working-directory",
              cwd,
              "--title",
              title,
              "--app-id",
              app_id,
            }, { detach = true })
          end, { desc = "Open foot terminal in Neovide" })
        ''
      }

      vim.keymap.set(
        { "n", "v", "s", "x", "o", "i", "l", "c", "t" },
        "<C-S-v>",
        function() vim.api.nvim_paste(vim.fn.getreg "+", true, -1) end,
        { noremap = true, silent = true }
      )
    end
  '';
}
