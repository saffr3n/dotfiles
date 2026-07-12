{ pkgs, ... }: {
  imports = [
    ./hardware.nix
    ./nvidia.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  services.upower.enable = true;
  powerManagement.cpuFreqGovernor = "performance";
  services.udev.extraRules = ''
    ACTION=="add|change",        \
    SUBSYSTEM=="block",          \
    KERNEL=="sd[a-z]",           \
    ATTR{queue/rotational}=="1", \
    RUN+="${pkgs.hdparm}/bin/hdparm -B 255 -S 0 /dev/%k"
  '';

  services.udisks2.enable = true;

  hardware.bluetooth.enable = true;

  systemd.network.wait-online.enable = false;
  networking = {
    nameservers = [ "127.0.0.1" ];
    networkmanager = {
      enable = true;
      dns = "none";
    };
  };

  systemd.services.dnscrypt-proxy.serviceConfig.StateDirectory = "dnscrypt-proxy";
  services.dnscrypt-proxy = {
    enable = true;
    settings = {
      sources.public-resolvers = {
        urls = [
          "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
          "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
        ];
        minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
        cache_file = "/var/lib/dnscrypt-proxy/public-resolvers.md";
      };
      ipv6_servers = false;
      block_ipv6 = true;
      require_dnssec = true;
      require_nolog = true;
      require_nofilter = true;
      server_names = [ "cloudflare" ];
    };
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
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

  time.timeZone = "Europe/Istanbul";
  i18n.defaultLocale = "en_US.UTF-8";

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  programs.steam.enable = true;

  documentation.dev.enable = true;

  environment.systemPackages = with pkgs; [
    man-pages
    man-pages-posix

    git
    gnumake
    vim
  ];

  fonts.enableDefaultPackages = true;

  system.stateVersion = "25.11";
}
