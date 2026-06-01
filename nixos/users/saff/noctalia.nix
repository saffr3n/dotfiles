{ config, pkgs, ... }: let
  dotfilesDir = "${config.home.homeDirectory}/.dotfiles";
in {
  home = {
    packages = with pkgs; [
      noctalia-shell
      qt6Packages.qt6ct
      nwg-look
      adw-gtk3
      papirus-icon-theme
    ];

    sessionVariables = {
      QT_QPA_PLATFORMTHEME = "qt6ct";
    };
  };

  xdg.configFile."noctalia/settings.json".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/noctalia/settings.json";
  xdg.configFile."qt6ct/qt6ct.conf".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/qt6ct/qt6ct.conf";
}
