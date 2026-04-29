{ config, pkgs, ... }: {
  imports = [
    ./hyprland.nix
    ./kitty.nix
    ./neovim.nix
  ];

  home = {
    homeDirectory = "/home/${config.home.username}";

    packages = with pkgs; [
      zen-browser
    ];

    stateVersion = "25.11";
  };
}
