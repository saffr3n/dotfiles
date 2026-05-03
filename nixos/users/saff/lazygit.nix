{ config, pkgs, ... }: {
  home.packages = [ pkgs.lazygit ];

  xdg.configFile.lazygit = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/lazygit";
    recursive = true;
  };
}
