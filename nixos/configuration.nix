{ pkgs, ... }: {
  imports = [ ./hardware.nix ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = "nixos-btw";
    networkmanager.enable = true;
  };

  time.timeZone = "Europe/Istanbul";
  i18n.defaultLocale = "en_US.UTF-8";

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
  };

  users.users.saff = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    neovim
    vim
    git
  ];

  system.stateVersion = "25.11";
}
