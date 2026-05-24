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

  programs.bash.bashrcExtra = ''
    function cd() {
      builtin cd "$@"
      [[ -z "$NVIM" ]] && return
      nvim --server "$NVIM" --remote-expr "chdir('$(pwd)')"
    }
  '';

  xdg.configFile.nvim = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/nvim";
    recursive = true;
  };
}
