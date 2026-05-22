{ config, pkgs, ... }: {
  home.packages = [ pkgs.git ];

  xdg.configFile.git = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/git";
    recursive = true;
  };
}
