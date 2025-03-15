{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    impermanence.url = "github:nix-community/impermanence";

    # use ssh protocol to authenticate via ssh-agent/ssh-key, and shallow clone to save time
    #secrets = {
    #  url = "git+ssh://git@github.com/taylorjonl/nix-secrets.git?shallow=1";
    #  flake = false;
    #};
  };

  outputs = { self, nixpkgs, impermanence, ... }@inputs:
  let
    system = "x86_64-linux";
  in {
    nixosConfigurations = {
      callisto = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          impermanence.nixosModules.impermanence
          ./hosts/callisto
          ./system
        ];
      };
      ganymede = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/ganymede
          ./system
        ];
      };
    };
  };
}
