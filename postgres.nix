{ pkgs, ... }: {
  services.postgresql = {
    package = pkgs.postgresql_13;
    enable = true;
    enableTCPIP = true;
    unix_socket_perms = "0770";
  };
}
