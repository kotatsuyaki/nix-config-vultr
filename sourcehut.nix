# vim: set ts=2 sts=2 sw=2 et is si:
{ pkgs, lib, config, ... }:
let
  fqdn = "kotatsu.tk";
  # let
  #   join = hostName: domain: hostName + optionalString (domain != null) ".${domain}";
  # in join config.networking.hostName config.networking.domain;
  images = {
    nixos.unstable.x86_64 =
      let
        systemConfig = { pkgs, ... }: {
          # passwordless ssh server
          services.openssh = {
            enable = true;
            permitRootLogin = "yes";
            extraConfig = "PermitEmptyPasswords yes";
          };

          users = {
            mutableUsers = false;
            # build user
            extraUsers."build" = {
              isNormalUser = true;
              uid = 1000;
              extraGroups = [ "wheel" ];
              password = "";
            };
            users.root.password = "";
          };

          security.sudo.wheelNeedsPassword = false;
          nix.settings.trusted-users = [ "root" "build" ];
          documentation.nixos.enable = false;

          # builds.sr.ht-image-specific network settings
          networking = {
            hostName = "build";
            dhcpcd.enable = false;
            defaultGateway.address = "10.0.2.2";
            usePredictableInterfaceNames = false;
            interfaces."eth0".ipv4.addresses = [{
              address = "10.0.2.15";
              prefixLength = 25;
            }];
            enableIPv6 = false;
            nameservers = [
              # OpenNIC anycast
              "185.121.177.177"
              "169.239.202.202"
              # Google
              "8.8.8.8"
            ];
            firewall.allowedTCPPorts = [ 22 ];
          };

          environment.systemPackages = [
            pkgs.gitMinimal
            #pkgs.mercurial
            pkgs.curl
            pkgs.gnupg
          ];
        };
        qemuConfig = { pkgs, ... }: {
          imports = [ systemConfig ];
          fileSystems."/".device = "/dev/disk/by-label/nixos";
          boot.initrd.availableKernelModules = [
            "ahci"
            "ehci_pci"
            "sd_mod"
            "usb_storage"
            "usbhid"
            "virtio_balloon"
            "virtio_blk"
            "virtio_pci"
            "virtio_ring"
            "xhci_pci"
          ];
          boot.loader = {
            grub = {
              version = 2;
              device = "/dev/vda";
            };
            timeout = 0;
          };
        };
        config = (import (pkgs.path + "/nixos/lib/eval-config.nix") {
          inherit pkgs; modules = [ qemuConfig ];
          system = "x86_64-linux";
        }).config;
      in
      import (pkgs.path + "/nixos/lib/make-disk-image.nix") {
        inherit pkgs lib config;
        diskSize = 16000;
        format = "qcow2-compressed";
        contents = [
          {
            source = pkgs.writeText "gitconfig" ''
              [user]
                name = builds.sr.ht
                email = build@sr.ht
            '';
            target = "/home/build/.gitconfig";
            user = "build";
            group = "users";
            mode = "644";
          }
        ];
      };
  };
in
{
  environment.systemPackages = with pkgs; [
    gitMinimal
  ];
  services.sourcehut = {
    enable = true;

    git.enable = true;
    meta.enable = true;
    builds = {
      enable = true;
      enableWorker = true;
      inherit images;
    };

    nginx.enable = true;
    postgresql.enable = true;
    redis.enable = true;

    services = [
      "git"
      "meta"
      "builds"
    ];

    settings = {
      "sr.ht" = {
        environment = "production";
        global-domain = fqdn;
        origin = "https://${fqdn}";
        # Produce keys with srht-keygen from sourcehut.coresrht.
        network-key = "/var/lib/keys/srht-network-secret-key.txt";
        service-key = "/var/lib/keys/srht-service-secret-key.txt";
      };
      "builds.sr.ht" = {
        oauth-client-secret = "/var/lib/keys/srht-builds-oauth-client-secret.txt";
        oauth-client-id = "c324ae43fbfcb170";
      };
      "git.sr.ht" = {
        oauth-client-secret = "/var/lib/keys/srht-git-oauth-client-secret.txt";
        oauth-client-id = "9802473292668d6e";
      };
      "man.sr.ht" = {
        oauth-client-secret = "/var/lib/keys/srht-man-oauth-client-secret.txt";
        oauth-client-id = "962a22e26b5a826e";
      };
      webhooks.private-key = "/var/lib/keys/srht-webhook-private-key.txt";
    };
  };

  security.acme.certs."${fqdn}".extraDomainNames = [
    "meta.${fqdn}"
    "man.${fqdn}"
    "git.${fqdn}"
    "builds.${fqdn}"
  ];

  services.nginx = {
    enable = true;
    # only recommendedProxySettings are strictly required, but the rest make sense as well.
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;

    # Settings to setup what certificates are used for which endpoint.
    virtualHosts = {
      "${fqdn}".enableACME = true;
      "builds.${fqdn}".useACMEHost = fqdn;
      "meta.${fqdn}".useACMEHost = fqdn;
      "man.${fqdn}".useACMEHost = fqdn;
      "git.${fqdn}".useACMEHost = fqdn;
    };
  };

  services.postgresql = {
    package = pkgs.postgresql_13;
    enable = true;
    enableTCPIP = true;
    settings.unix_socket_permissions = "0770";
  };

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "robinhuang123@gmail.com";
}
