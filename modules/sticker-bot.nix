{ pkgs, tg-sticker-bot, ... }:
let
  # Run the bot as user
  user = "stickerbot";

  # Postgres DB name to be used for sticker tags
  database = "stickers";

  # Make sure that these secrets are in place
  stickers-secret = "/var/lib/keys/stickers-secret";
  stickers-bot-token = "/var/lib/keys/stickers-bot-token";

  sticker-bot = tg-sticker-bot.defaultPackage."x86_64-linux";

  # Wrapper script that reads secrets into environment variables
  start-script = pkgs.writeShellScript "start-sticker-bot" ''
    if [[ ! -f "${stickers-secret}" ]]; then
        >&2 echo 'stickers-secret file not found in ${stickers-secret}'; exit 1
    fi
    if [[ ! -f "${stickers-bot-token}" ]]; then
        >&2 echo 'stickers-bot-token file not found in ${stickers-bot-token}'; exit 1
    fi

    export DB_URL=postgres:///${database}
    export STICKERS_SECRET=`cat ${stickers-secret}`
    export TELOXIDE_TOKEN=`cat ${stickers-bot-token}`

    exec ${sticker-bot}/bin/sticker-search
  '';
in
{
  users.users."${user}" = {
    description = "Telegram sticker search bot service user";
    isSystemUser = true;
    group = "${user}";
  };
  users.groups."postgres".members = [ user ];
  users.groups."${user}" = { };

  services.postgresql = {
    # Trust connection to unix socket
    authentication = ''
      local ${database} ${user} trust
    '';
    ensureDatabases = [ database ];

    # Grant full privileges to bot user
    ensureUsers = [
      {
        name = user;
        ensurePermissions = {
          "DATABASE \"${database}\"" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  systemd.services.sticker-bot = {
    description = "Telegram sticker search bot instance";
    after = [
      "network.target"
      "postgresql.service"
    ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStart = "${start-script}";
      User = user;
    };
  };
}
