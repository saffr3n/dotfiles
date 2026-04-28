{ config, pkgs, ... }: {
  home.packages = [ pkgs.kitty ];

  xdg.configFile.kitty = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/kitty";
    recursive = true;
  };
}
