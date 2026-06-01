{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    noctalia-shell
    qt6Packages.qt6ct
    papirus-icon-theme
  ];

  xdg.configFile."noctalia/settings.json".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/noctalia/settings.json";
}
