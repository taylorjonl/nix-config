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

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    starship
  ];

  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 443 ];
    };
    hostId = "1bc05b34";
    hostName = "callisto";
    interfaces = {
      enp1s0f0.useDHCP = lib.mkDefault true;
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "taylorjonl@gmail.com";
    certs."home.theoverengineer.io" = {
      domain = "home.theoverengineer.io";
      extraDomainNames = [ "*.home.theoverengineer.io" ];
      dnsProvider = "cloudflare";
      dnsPropagationCheck = true;
      credentialsFile = "/persist/secrets/credentials.txt";
    };
  };

  services = {
    grafana = {
      enable = true;
      settings = {
        server = {
          domain = "grafana.home.theoverengineer.io";
          http_addr = "127.0.0.1";
          http_port = 3000;
          protocol = "http";
        };
      };
    };
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
    prometheus = {
      enable = true;
      port = 9090;
      exporters = {
        node = {
          enable = true;
          enabledCollectors = [ "systemd" ];
          port = 9100;
        };
      };
      globalConfig = {
        scrape_interval = "15s";
        evaluation_interval = "15s";
      };
      scrapeConfigs = [
        {
          job_name = "node";
          static_configs = [
            {
              targets = [ "callisto:9100" ];
            }
          ];
          relabel_configs = [
            {
              source_labels = [ "__address__" ];
              target_label = "instance";
              regex = "(.+):9100";
              replacement = "\${1}";
            }
          ];
        }
      ];
    };
    traefik = {
      enable = true;
      staticConfigOptions = {
        global = {
          checkNewVersion = false;
          sendAnonymousUsage = false;
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
        providers.docker.exposedByDefault = false;
      };
      dynamicConfigOptions = {
        http.routers.grafana = {
          rule = "Host(`grafana.home.theoverengineer.io`)";
          entryPoints = [ "websecure" ];
          service = "grafana";
          tls = {
            domains = {
              main = [ "home.theoverengineer.io" ];
              sans = [ "*.home.theoverengineer.io" ];
            };
          };
        };
        http.services.grafana = {
          loadBalancer.servers = [{
              url = "http://127.0.0.1:3000";
          }];
        };
        tls = {
          stores.default = {
            defaultCertificate = {
              certFile = "/var/lib/acme/home.theoverengineer.io/cert.pem";
              keyFile = "/var/lib/acme/home.theoverengineer.io/key.pem";
            };
          };

          certificates = [
            {
              certFile = "/var/lib/acme/home.theoverengineer.io/cert.pem";
              keyFile = "/var/lib/acme/home.theoverengineer.io/key.pem";
              stores = "default";
            }
          ];
        };
      };
    };
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
  users.users.traefik.extraGroups = [ "docker" "acme" ];

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
