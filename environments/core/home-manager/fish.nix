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
    binds = {
      "alt-u".command = "systemctl-list-units user";
      "alt-s".command = "systemctl-list-units";
    };
    shellAliases = {
      ls = "${pkgs.eza}/bin/eza -lah";
      cat = "${pkgs.bat}/bin/bat";
      lg = "${pkgs.lazygit}/bin/lazygit";
      g = "${pkgs.lazygit}/bin/lazygit";
      du = "${pkgs.dust}/bin/dust";
      jq = "${pkgs.gojq}/bin/gojq";
      v = "nvim";
      tree = "${pkgs.tre-command}/bin/tre";
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
