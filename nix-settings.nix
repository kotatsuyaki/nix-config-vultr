{ pkgs, nixpkgs, ... }: {
  nix.package = pkgs.nixFlakes;
  nix.settings.trusted-users = [ "root" "taki" ];
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  nix.registry.nixpkgs.flake = nixpkgs;
}
