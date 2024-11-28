{ config, lib, ... }:
{
  boot = {
    kernelModules = [ "kvm-intel" "wl" ];
    extraModulePackages = [
      config.boot.kernelPackages.broadcom_sta
    ];
    initrd = {
      availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "firewire_ohci" "usbhid" "usb_storage" "sd_mod" "sdhci_pci" ];
      kernelModules = [ ];
    };
  };
}
