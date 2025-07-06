{ config, ... }:
let
  secretFile = ../../../secrets/ai.yaml;
in
{
  sops.secrets."ai/gemini/api_key".sopsFile = secretFile;
  sops.secrets."ai/anthropic/api_key".sopsFile = secretFile;
  sops.secrets."ai/deepseek/api_key".sopsFile = secretFile;
  programs.nixvim = {
    plugins.codecompanion = {
      enable = true;
      settings = {
        strategies = {
          chat.adapter = "anthropic";
          inline.adapter = "anthropic";
          agent.adapter = "anthropic";
        };
        adapters = {
          anthropic.__raw = ''
            function()
              return require("codecompanion.adapters").extend("anthropic", {
                env = {
                  api_key = [[cmd:cat ${config.sops.secrets."ai/anthropic/api_key".path}]],
                }
              })
            end
          '';
          gemini.__raw = ''
            function()
              return require("codecompanion.adapters").extend("gemini", {
                env = {
                  api_key = [[cmd:cat ${config.sops.secrets."ai/gemini/api_key".path}]],
                }
              })
            end
          '';
          deepseek.__raw = ''
            function()
              return require("codecompanion.adapters").extend("deepseek", {
                env = {
                  api_key = [[cmd:cat ${config.sops.secrets."ai/deepseek/api_key".path}]],
                }
              })
            end
          '';
        };
      };
      lazyLoad.settings.cmd = [
        "CodeCompanionActions"
        "CodeCompanionChat"
      ];
      lazyLoad.settings.keys =
        let
          map =
            key: action:
            {
              mode ? [ "n" ],
              desc ? "",
            }:
            {
              __unkeyed-1 = key;
              __unkeyed-2 = action;
              inherit mode desc;
            };
        in
        [
          (map "<localleader>c" "<cmd>CodeCompanionActions<cr>" {
            desc = "Code Companion Actions";
            mode = [
              "n"
              "v"
            ];
          })
          (map "<localleader>C" "<cmd>CodeCompanionChat Toggle<cr>" {
            desc = "Code Companion Chat";
            mode = [
              "n"
              "v"
            ];
          })
        ];
    };
  };
}
