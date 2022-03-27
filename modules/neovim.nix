{ pkgs, ... }: {
  programs.neovim = {
    enable = true;
    vimAlias = true;
    configure.customRC = ''
      lua << EOF
      require('nightfox').load('dayfox')
      require('nvim-treesitter.configs').setup {
        highlight = {
          enable = true,
        },
      }
      EOF
    '';
    configure.packages.mypkg = with pkgs.vimPlugins; {
      start = [
        vim-surround
        nightfox-nvim
        (nvim-treesitter.withPlugins (plugins: with plugins; [
          tree-sitter-nix
        ]))
      ];
    };
  };
}
