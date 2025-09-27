{
  services.cliphist = {
    enable = true;
    extraOptions = [
      # The default options store huge amount of history. Querying the history is slow. So we limit it.
      "-max-items"
      "200"
      "max-dedupe-search"
      "10"
    ];
  };
}
