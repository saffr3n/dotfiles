{ config, pkgs, ... }: {
  home = {
    packages = with pkgs; [
      grimblast
      wl-clipboard
    ];

    sessionVariables = {
      NIXOS_OZONE_WL = 1;
    };
  };


  xdg.configFile.hypr = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/hypr";
    recursive = true;
  };
}
