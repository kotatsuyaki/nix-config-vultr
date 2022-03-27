{ pkgs, ... }: {
  services.postgresql = {
    package = pkgs.postgresql_13;
    enable = true;
    enableTCPIP = true;
    settings.unix_socket_permissions = "0770";
  };
}
