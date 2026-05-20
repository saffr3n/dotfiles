{ config, pkgs, ... }: {
  home = {
    packages = with pkgs; [
      neovim
      tree-sitter
      nixd
      emmylua-ls
    ];

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  xdg.configFile.nvim = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/nvim";
    recursive = true;
  };
}
