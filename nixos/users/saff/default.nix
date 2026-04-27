{ config, pkgs, ... }: {
  imports = [
    ./hyprland.nix
    ./neovim.nix
  ];

  home = {
    homeDirectory = "/home/${config.home.username}";

    packages = with pkgs; [
      kitty
      firefox
    ];

    stateVersion = "25.11";
  };
}
