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

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
      setSessionVariables = true;
      extraConfig = {
        SCREENSHOTS = "${config.xdg.userDirs.pictures}/Screenshots";
      };
    };
  };

  services = {
    udiskie = {
      enable = true;
      settings.program_options.file_manager = "kitty -e yazi";
    };
  };
}
