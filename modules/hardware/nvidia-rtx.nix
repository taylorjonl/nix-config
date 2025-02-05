{ config, pkgs, ... }:
{
  hardware.nvidia = {
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    powerManagement = {
      enable = true;
    };
  };
  services.xserver.videoDrivers = ["nvidia"];
}
