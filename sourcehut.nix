# vim: set ts=2 sts=2 sw=2 et is si:
{ pkgs, ... }:
let
  fqdn = "kotatsu.tk";
  # let
  #   join = hostName: domain: hostName + optionalString (domain != null) ".${domain}";
  # in join config.networking.hostName config.networking.domain;
in
{
  environment.systemPackages = with pkgs; [
    gitMinimal
  ];
  services.sourcehut = {
    enable = true;

    git.enable = true;
    # man.enable = true;
    meta.enable = true;

    nginx.enable = true;
    postgresql.enable = true;
    redis.enable = true;

    services = [
      "git"
      "meta"
      # "man"
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
      # "builds.sr.ht" = {
      #   oauth-client-secret = "/var/lib/keys/srht-builds-oauth-client-secret.txt";
      #   # pkgs.writeText "buildsrht-oauth-client-secret" "2260e9c4d9b8dcedcef642860e0504bc";
      #   oauth-client-id = "c324ae43fbfcb170";
      # };
      "git.sr.ht" = {
        oauth-client-secret = "/var/lib/keys/srht-git-oauth-client-secret.txt";
        # oauth-client-secret = pkgs.writeText "gitsrht-oauth-client-secret" "3597288dc2c716e567db5384f493b09d";
        oauth-client-id = "9802473292668d6e";
      };
      "man.sr.ht" = {
        oauth-client-secret = "/var/lib/keys/srht-man-oauth-client-secret.txt";
        # oauth-client-secret = pkgs.writeText "mansrht-oauth-client-secret" "3597288dc2c716e567db5384f493b09d";
        oauth-client-id = "962a22e26b5a826e";
      };
      webhooks.private-key = "/var/lib/keys/srht-webhook-private-key.txt";
    };
  };

  security.acme.certs."${fqdn}".extraDomainNames = [
    "meta.${fqdn}"
    "man.${fqdn}"
    "git.${fqdn}"
    # "builds.${fqdn}"
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
      # "builds.${fqdn}".useACMEHost = fqdn;
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
