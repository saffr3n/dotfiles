{ config, pkgs, ... }: {
  imports = [
    ./btop.nix
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
      fastfetch
      fd
      fzf
      ripgrep

      imv
      mpv
      zen-browser

      nerd-fonts.jetbrains-mono
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
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

  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      serif = [ "Noto Serif" ];
      sansSerif = [ "Noto Sans" ];
      monospace = [ "JetBrainsMono Nerd Font Mono" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };
}
