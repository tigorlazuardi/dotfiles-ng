{
  programs.zoxide = {
    enable = true;
    flags = [
      "--cmd"
      "cd"
      "--hook"
      "prompt"
    ];
  };
}
