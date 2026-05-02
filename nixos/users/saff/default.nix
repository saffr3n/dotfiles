{ config, pkgs, ... }: {
  imports = [
    ./hyprland.nix
    ./kitty.nix
    ./neovim.nix
    ./yazi.nix
  ];

  home = {
    homeDirectory = "/home/${config.home.username}";

    packages = with pkgs; [
      imv
      mpv
      zen-browser
    ];

    stateVersion = "25.11";
  };
}
