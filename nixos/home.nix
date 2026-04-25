{ config, pkgs, ... }: let
  username = "saff";
in {
  home = {
    inherit username;
    homeDirectory = "/home/${username}";

    sessionVariables = {
      NIXOS_OZONE_WL = 1;
    };

    packages = with pkgs; [
      kitty
      neovim
      firefox
    ];

    stateVersion = "25.11";
  };

  wayland.windowManager.hyprland.systemd.enable = false;

  xdg.configFile.hypr = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/hypr";
    recursive = true;
  };
}
