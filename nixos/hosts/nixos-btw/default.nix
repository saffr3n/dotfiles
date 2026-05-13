{ pkgs, ... }: {
  imports = [
    ./hardware.nix
    ./nvidia.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  powerManagement.cpuFreqGovernor = "performance";
  services.udev.extraRules = ''
    ACTION=="add|change",        \
    SUBSYSTEM=="block",          \
    KERNEL=="sd[a-z]",           \
    ATTR{queue/rotational}=="1", \
    RUN+="${pkgs.hdparm}/bin/hdparm -B 255 -S 0 /dev/%k"
  '';

  services.udisks2.enable = true;

  systemd.network.wait-online.enable = false;
  networking.networkmanager.enable = true;

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

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };

  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings.main = {
        capslock = "overload(control, esc)";
        esc = "capslock";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  system.stateVersion = "25.11";
}
