{ config, pkgs, ... }: {
  home.packages = [ pkgs.yazi ];

  xdg.configFile.yazi = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/yazi";
    recursive = true;
  };
}
