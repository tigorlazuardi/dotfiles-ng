{ ... }:
{
  programs.nixvim = {
    plugins = {
      friendly-snippets.enable = true;
      blink-ripgrep = {
        enable = true;
        lazyLoad.settings.ft = [ "manually_loaded" ];
      };
      blink-cmp = {
        enable = true;
        settings = {
          appearance.nerd_font_variant = "mono";
          cmdline = {
            enabled = true;
            keymap = {
              preset = "cmdline";
            };
            completion.menu.auto_show = true;
          };
          completion = {
            list.selection.auto_insert = false;
            accept.auto_brackets.enabled = true;
            ghost_text.enabled = false;
            documentation = {
              auto_show = true;
              auto_show_delay_ms = 300;
              window.border = "rounded";
            };
            menu = {
              border = "rounded";
              draw = {
                treesitter = [ "lsp" ];
                columns = [
                  [ "kind_icon" ]
                  [
                    "label"
                    "label_description"
                  ]
                  [ "kind" ]
                ];
                components = {
                  kind_icon = {
                    ellipsis = false;
                    text.__raw = # lua
                      ''
                        function(ctx)
                           local miniIcons = require "mini.icons"
                           if ctx.kind == "Folder" then
                               return miniIcons.get("directory", ctx.label)
                           end
                           if ctx.kind == "File" then
                               return miniIcons.get("file", ctx.label)
                           end
                           if ctx.kind == "Copilot" then
                               return ""
                           end
                           local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
                           return kind_icon
                        end
                      '';
                    highlight.__raw = # lua
                      ''
                        function(ctx)
                            if ctx.kind == "Folder" then
                                local _, hl, _ = require("mini.icons").get("directory", ctx.label)
                                return hl
                            end
                            if ctx.kind == "File" then
                                local _, hl, _ = require("mini.icons").get("file", ctx.label)
                                return hl
                            end
                            if ctx.kind == "Copilot" then
                                local _, hl, _ = require("mini.icons").get("os", "nixos")
                                return hl
                            end
                            local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                            return hl
                        end
                      '';
                  };
                  kind = {
                    text.__raw = # lua
                      ''
                        function(ctx)
                          return " " .. ctx.kind
                        end
                      '';
                  };
                };
              };
            };
          };
          sources = {
            default = [
              "lsp"
              "path"
              "snippets"
              "ripgrep"
            ];
            providers.ripgrep = {
              module = "blink-ripgrep";
              name = "Ripgrep";
              score_offset = -1;
              max_items = 20;
              transform_items.__raw = ''
                function(_, items)
                  for _, item in ipairs(items) do
                    item.labelDetails = {
                      description = "(rg)";
                    }
                  end
                  return items
                end
              '';
              opts = {
                prefix_min_len = 3;
                backend.ripgrep = {
                  max_filesize = "200K";
                };
                project_root_marker = [
                  ".git"
                  "go.mod"
                  "package.json"
                  ".root"
                  ".envrc"
                ];
              };
            };
          };
          keymap.preset = "default";
        };
        lazyLoad.settings = {
          event = [
            "InsertEnter"
            "CmdlineEnter"
          ];
        };
      };
    };
  };
}
