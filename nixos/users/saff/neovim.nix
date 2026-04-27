{ config, pkgs, ... }: {
  home.sessionVariables.EDITOR = "nvim";

  home.packages = with pkgs; [
    neovim
  ];
}
