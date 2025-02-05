{ config, pkgs, ... }:
{
  imports = [
    ../services/xserver.nix
  ];

  hardware.pulseaudio.enable = false;

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
  };

  security.rtkit.enable = true;

  services = {
    displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true;
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
    };
    printing.enable = true;
  };
}
