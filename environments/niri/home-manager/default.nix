{
  imports = [
    # We will use Nemo as the default file manager.
    ../../gnome/home-manager/nemo.nix
  ];
  programs.niri = {
    settings = {
      input.keyboard.xkb.layout = "us";
    };
    portalConfig.preferred = {
      # Disable nautilus, and prefer to use Nemo as the file manager.
      "org.freedesktop.impl.portal.FileChooser" = "gtk;";
    };
  };
  # We will use the GNOME Polkit agent for Root ccess authorizations.
  services.polkit-gnome.enable = true;
}
