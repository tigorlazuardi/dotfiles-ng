{
  programs.nixvim.plugins.telescope = {
    enable = true;
    # Telescope will be used for plugins that needs it.
    #
    # There are no other usecases, so we just want to load it
    # on demand.
    #
    # Snacks.nvim already replace the usecase of Telescope.
    lazyLoad.settings.ft = [ "manually_loaded" ];
  };
}
