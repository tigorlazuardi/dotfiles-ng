{
  programs.git = {
    enable = true;
    extraConfig = {
      url."git@gitlab.bareksa.com:".insteadOf = "https://gitlab.bareksa.com";
      includeIf."gitdir:~/bareksa/".path = "~/bareksa/.gitconfig";
    };
  };
}
