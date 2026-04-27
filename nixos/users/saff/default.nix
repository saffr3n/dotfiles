{ config, pkgs, ... }: {
  imports = [
    ./hyprland.nix
  ];

  home = {
    homeDirectory = "/home/${config.home.username}";

    packages = with pkgs; [
      kitty
      neovim
      firefox
    ];

    stateVersion = "25.11";
  };
}
