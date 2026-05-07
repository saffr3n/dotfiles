{ config, pkgs, ... }: {
  home.sessionVariables.NIXOS_OZONE_WL = 1;

  home.packages = with pkgs; [
    grimblast
    wl-clipboard
  ];

  wayland.windowManager.hyprland.systemd.enable = false;

  xdg.configFile.hypr = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/hypr";
    recursive = true;
  };
}
