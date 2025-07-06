{
  programs.nixvim = {
    plugins.which-key = {
      enable = true;
      lazyLoad.settings.event = [ "DeferredUIEnter" ];
    };
    keymaps = [
      {
        action = "";
        key = "<leader>c";
        mode = "n";
        options.desc = "+code";
      }
    ];
  };
}
