{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    noctalia-shell
    papirus-icon-theme
  ];
}
