{ config, pkgs, ... }: {
  home.packages = [ pkgs.btop ];

  xdg.configFile.btop = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/btop";
    recursive = true;
  };
}
