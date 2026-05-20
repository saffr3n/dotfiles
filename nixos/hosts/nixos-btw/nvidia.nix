{ config, ... }: {
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
  };

  services.xserver.videoDrivers = [ "modesetting" "nvidia" ];

  hardware = {
    graphics.enable = true;
    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
      open = false;
      modesetting.enable = true;
      prime = {
        intelBusId = "PCI:0@0:2:0";
        nvidiaBusId = "PCI:1@0:0:0";
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
      };
    };
  };
}
