# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/vda";

  networking.hostName = "vultr";

  networking.useDHCP = false;
  networking.interfaces.enp1s0.useDHCP = true;

  environment.systemPackages = with pkgs; [
    btop
    ripgrep
    fd
  ];

  time.timeZone = "Asia/Taipei";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users.taki = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };

  services.openssh.enable = true;
  services.openssh.gatewayPorts = "yes";
  services.openssh.listenAddresses = [{
    addr = "0.0.0.0";
    port = 22;
  }];

  # Open ports in the firewall.
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 25565 ];
  networking.firewall.allowedUDPPorts = [ 25565 ];

  system.stateVersion = "21.11"; # Did you read the comment?
}

