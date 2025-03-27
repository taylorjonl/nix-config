{ config, lib, pkgs, ... }:
{
  imports = [
    ../common.nix
    ./filesystems.nix
    ./hardware.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.tmp.useTmpfs = true;

  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/var/lib/nixos"
      "/var/lib/traefik"
      "/var/log"
    ];
    files = [
      "/etc/machine-id"
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    starship
  ];

  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 443 9100 ];
    };
    hostId = "1bc05b34";
    hostName = "callisto";
    interfaces = {
      enp1s0f0.useDHCP = lib.mkDefault true;
    };
  };

  services = {
    openssh = {
      enable = true;
      hostKeys = [
        {
          path = "/persist/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
        {
          path = "/persist/ssh/ssh_host_rsa_key";
          type = "rsa";
          bits = 4096;
        }
      ];
      settings = {
        PasswordAuthentication = true;
        PermitRootLogin = "no";
      };
    };
    prometheus.exporters.node = {
      enable = true;
      port = 9100;
      # https://github.com/NixOS/nixpkgs/blob/nixos-24.05/nixos/modules/services/monitoring/prometheus/exporters.nix
      enabledCollectors = [ "systemd" ];
      # /nix/store/zgsw0yx18v10xa58psanfabmg95nl2bb-node_exporter-1.8.1/bin/node_exporter  --help
      #extraFlags = [ "--collector.ethtool" "--collector.softirqs" "--collector.tcpstat" "--collector.wifi" ];
    };
    traefik = {
      enable = true;
      staticConfigOptions = {
        global = {
          checkNewVersion = false;
          sendAnonymousUsage = false;
        };
        log = {
          level = "DEBUG";
          filePath = "/var/lib/traefik/traefik.log";
          format = "json";
        };
        entryPoints = {
          web = {
            address = ":80";
            http.redirections.entrypoint = {
              to = "websecure";
              scheme = "https";
            };
          };
          websecure.address = ":443";
        };
        certificatesResolvers.cloudflare.acme = {
          email = "taylorjonl@gmail.com";
          storage = "/var/lib/traefik/acme.json";
          dnsChallenge = {
            provider = "cloudflare";
            resolvers = [ "1.1.1.1:53" "1.0.0.1:53" ];
          };
        };
        providers.docker.exposedByDefault = false;
      };
    };
  };

  systemd.services.traefik.environment = {
    CF_DNS_API_TOKEN_FILE = "/persist/secrets/cloudflare.txt";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.mutableUsers = false;
  users.users.jltaylor = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ]; # Enable ‘sudo’ for the user.
    hashedPasswordFile = "/persist/passwords/jltaylor";
    #packages = with pkgs; [
    #  tree
    #];
  };
  users.users.traefik.extraGroups = [ "docker" ];

  virtualisation = {
    docker = {
      enable = true;
      storageDriver = "zfs";
    };
  };

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?
}
