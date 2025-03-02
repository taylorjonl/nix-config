{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../../modules/hardware/mac-mini-6.2.nix
  ];

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/DEA2-EBBB";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/d6dee856-1378-439b-b37a-e296401b2fab"; }
    { device = "/dev/disk/by-uuid/1c4db162-e60a-4df7-9cb5-7b4b94632255"; }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
