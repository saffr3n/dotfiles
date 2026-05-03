{ config, pkgs, ... }: {
  imports = [
    ./hyprland.nix
    ./kitty.nix
    ./lazygit.nix
    ./neovim.nix
    ./yazi.nix
  ];

  home = {
    homeDirectory = "/home/${config.home.username}";

    packages = with pkgs; [
      bat
      btop
      fastfetch
      fd
      fzf
      ripgrep

      imv
      mpv
      zen-browser
    ];

    stateVersion = "25.11";
  };
}
