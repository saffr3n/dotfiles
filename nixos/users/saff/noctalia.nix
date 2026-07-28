{ config, pkgs, ... }: let
  dotfilesDir = "${config.home.homeDirectory}/.dotfiles";
in {
  home = {
    packages = with pkgs; [
      noctalia
      qt6Packages.qt6ct
      nwg-look
      adw-gtk3
      papirus-icon-theme
    ];

    sessionVariables = {
      QT_QPA_PLATFORMTHEME = "qt6ct";
    };
  };

  xdg.configFile."noctalia/settings.json".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/noctalia/config.toml";
  xdg.configFile."qt6ct/qt6ct.conf".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/qt6ct/qt6ct.conf";
  xdg.configFile."nwg-look/config".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/nwg-look/config";
  xdg.configFile."gtk-3.0/settings.ini".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/gtk-3.0/settings.ini";
  xdg.configFile."gtk-4.0/settings.ini".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/gtk-4.0/settings.ini";
}
