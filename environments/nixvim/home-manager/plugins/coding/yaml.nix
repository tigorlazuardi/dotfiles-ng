{
  programs.nixvim = {
    extraFiles."queries/yaml/injections.scm".text =
      # query
      ''
        ; extends

        ; create highlight based on the comment before the key-value pair.
        (
          [
            ; inline comment
            ;
            ; foo: | # json
            ;  {
            ;    "foo": 123
            ;  }
            (
              (block_scalar (comment) @injection.language) @injection.content
            )
            ; putting `# lang` syntax before a field has a weird
            ; tree, especially for the second one below.
            ;
            ; Does not work for top-most very first field in the text file.
            ; You have to use inline comment for that.
            ;
            ; Usecase:
            ;
            ; # json
            ; foo: |
            ;   {
            ;     "foo": bar
            ;   }
            (
              (comment) @injection.language .
              (block_mapping_pair
                value: (block_node (block_scalar) @injection.content)
              )
            )
            (
              (_(_(_ (comment) @injection.language)))
              (block_mapping_pair
                value: (block_node (block_scalar) @injection.content)
              )
            )
            ; Top level document
            (
              (comment) @injection.language .
              (document (
                block_node (
                  block_mapping . (
                    block_mapping_pair
                    _ (block_node (block_scalar) @injection.content)
              ))))
            )
          ]
          (#offset! @injection.content 0 1 0 0)
          (#gsub! @injection.language "#%s*([%w%p]+)%s*" "%1")
        )
      '';
    plugins.lsp.servers.yamlls = {
      enable = true;
      extraOptions.capabilities.__raw = ''
        require("blink.cmp").get_lsp_capabilities({}, true)
      '';
    };
    plugins.conform-nvim.settings.formatters_by_ft = {
      yaml = [ "prettierd" ];
    };
    plugins.schemastore.enable = true;
  };
}
