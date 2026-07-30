{ config, pkgs, ... }: {
  home.packages = [ pkgs.bat ];

  xdg.configFile.bat = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/bat";
    recursive = true;
  };
}
