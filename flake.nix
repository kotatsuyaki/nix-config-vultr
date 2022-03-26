{
  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;

  outputs = { self, nixpkgs, ... } @attrs: {
    nixosConfigurations.gitserver = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [
        ./configuration.nix
        ./neovim.nix
        ./nix-settings.nix
        ./tmux.nix
        ./postgres.nix
      ];
    };
  };
}
