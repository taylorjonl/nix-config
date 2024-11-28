{ lib, ... }:
{
  imports = [
    #impermanence.nixosModules.impermanence
  ];

  environment.systemPackages = [
    #pkgs.ncdu # `sudo ncdu -x /`
  ];

  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/var/lib/nixos"
      "/var/log"
    ];
    files = [
      "/etc/machine-id"
    ];
  };

  boot.initrd.postResumeCommands = lib.mkAfter ''
    zfs rollback -r tank/transient/rootfs@fresh
  '';

  fileSystems = {
    "/" = {
      device = "tank/transient/rootfs";
      fsType = "zfs";
    };
    "/home" = {
      device = "tank/persistent/home";
      fsType = "zfs";
    };
    "/nix" = {
      device = "tank/impermanent/nix";
      fsType = "zfs";
    };
    "/persist" = {
      device = "tank/persistent/persist";
      fsType = "zfs";
      neededForBoot = true;
    };
  };
}
