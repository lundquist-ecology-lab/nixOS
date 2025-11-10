{
  description = "NixOS configuration to mirror the existing Arch setup on moria";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sysc-greet-src = {
      url = "github:lundquist-ecology-lab/sysc-greet/master";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, sysc-greet-src, ... }@inputs:
    let
      system = "x86_64-linux";
      unstablePkgs = import nixpkgs-unstable {
        inherit system;
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [
            "qtwebengine-5.15.19"
          ];
        };
      };
      overlays = [
        (final: prev: {
          sysc-greet = prev.callPackage ./pkgs/sysc-greet {
            src = sysc-greet-src;
            version = "local";
            go_1_25 = unstablePkgs.go_1_25 or unstablePkgs.go;
          };
        })
      ];
    in
    {
      packages.${system} =
        let
          pkgsForPackages = import nixpkgs {
            inherit system;
            overlays = overlays;
            config = {
              allowUnfree = true;
              permittedInsecurePackages = [
                "qtwebengine-5.15.19"
              ];
            };
          };
        in
        {
          sysc-greet = pkgsForPackages.sysc-greet;
          default = pkgsForPackages.sysc-greet;
        };

      nixosConfigurations = {
        moria = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit unstablePkgs inputs;
          };
          modules = [
            { nixpkgs.overlays = overlays; }
            ./hosts/moria/configuration.nix
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

        edoras = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit unstablePkgs inputs;
          };
          modules = [
            { nixpkgs.overlays = overlays; }
            ./hosts/edoras/configuration.nix
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
    };
}
