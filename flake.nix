{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;

    tg-sticker-bot.url = github:kouakitaki/telegram-sticker-search-bot/master;
    tg-sticker-bot.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, ... } @ attrs: {
    nixosConfigurations.gitserver = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = nixpkgs.lib.filesystem.listFilesRecursive ./modules;
    };
  };
}
