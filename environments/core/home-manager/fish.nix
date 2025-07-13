{ pkgs, ... }:
{
  home.packages = with pkgs; [ grc ];
  # Add color to commands
  programs.carapace.enable = true;
  programs.fzf.enable = true;
  programs.fish = {
    enable = true;
    functions = {
      fish_greeting = "";
    };
    shellAliases = {
      ls = "${pkgs.eza}/bin/eza -lah";
      cat = "${pkgs.bat}/bin/bat";
      lg = "${pkgs.lazygit}/bin/lazygit";
      g = "${pkgs.lazygit}/bin/lazygit";
      du = "${pkgs.dust}/bin/dust";
      jq = "${pkgs.gojq}/bin/gojq";
      v = "nvim";
      cd = "z";
      tree = "${pkgs.tre-command}/bin/tre";
    };
    shellAbbrs = {
      update = "nh os switch -- --accept-flake-config";
      superupdate = "nh os switch --update -- --accept-flake-config";
      uptest = "nh os test -- --accept-flake-config";
      dry = "sudo nixos-rebuild dry-activate --flake $HOME/dotfiles";
    };
    interactiveShellInit = # fish
      ''
        set --universal hydro_multiline true
        set --universal fish_prompt_pwd_dir_length 30
        set --universal hydro_symbol_start (set_color normal; echo "[")(set_color yellow; echo "$(whoami)")(set_color normal; echo "@")(set_color green; echo "$(hostname)")(set_color normal; echo "]")\ 
      '';
    plugins = with pkgs.fishPlugins; [
      {
        name = "hydro";
        src = hydro.src;
      }
      {
        name = "grc";
        src = grc.src;
      }
      {
        name = "fzf";
        src = fzf.src;
      }
    ];
  };
}
