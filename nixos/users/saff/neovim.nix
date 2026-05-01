{ config, pkgs, ... }: {
  home.sessionVariables.EDITOR = "nvim";

  home.packages = with pkgs; [
    neovim
    tree-sitter
    nixd
    emmylua-ls
  ];

  xdg.configFile.nvim = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/nvim";
    recursive = true;
  };
}
