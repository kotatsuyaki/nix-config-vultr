{ pkgs, ... }: {
  services.postgresql = {
    package = pkgs.postgresql_13;
    enable = true;
    enableTCPIP = false;
    settings.unix_socket_permissions = "0770";
  };
}
