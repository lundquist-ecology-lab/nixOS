{
  description = "NixOS configuration to mirror the existing Arch setup on moria";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sysc-greet-src = {
      url = "git+ssh://git@github.com/lundquist-ecology-lab/sysc-greet.git?ref=master";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, sysc-greet-src, ... }@inputs:
    let
      system = "x86_64-linux";
      overlays = [
        (final: prev: {
          sysc-greet = prev.callPackage ./pkgs/sysc-greet {
            src = sysc-greet-src;
            version = "local";
          };
        })
      ];
      unstablePkgs = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      packages.${system} =
        let
          pkgsForPackages = import nixpkgs {
            inherit system;
            overlays = overlays;
            config.allowUnfree = true;
          };
        in
        {
          sysc-greet = pkgsForPackages.sysc-greet;
          default = pkgsForPackages.sysc-greet;
        };

      nixosConfigurations.moria = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit unstablePkgs inputs;
        };
        modules = [
          { nixpkgs.overlays = overlays; }
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit unstablePkgs inputs;
            };
            home-manager.users.mlundquist = import ./home/mlundquist.nix;
          }
        ];
      };
    };
}
