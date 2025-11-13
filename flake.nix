{
  description = "NixOS configuration to mirror the existing Arch setup on moria";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sysc-greet-src = {
      url = "github:lundquist-ecology-lab/sysc-greet/master";
      flake = false;
    };
    nix-ai-tools = {
      url = "github:numtide/nix-ai-tools";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, sysc-greet-src, nix-ai-tools, ... }@inputs:
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
          tela-icon-theme = prev.callPackage ./pkgs/tela-icon-theme { };
          paradise-gtk-theme = prev.callPackage ./pkgs/paradise-gtk-theme { };
          polycat = prev.callPackage ./pkgs/polycat { };
          orca-slicer-bin = prev.callPackage ./pkgs/orca-slicer-bin { };
        })
        # Add nix-ai-tools packages
        (final: prev:
          nix-ai-tools.packages.${system}
        )
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
          orca-slicer-bin = pkgsForPackages.orca-slicer-bin;
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
              home-manager.backupFileExtension = "hm-bak";
              home-manager.extraSpecialArgs = {
                inherit unstablePkgs inputs;
                hostname = "moria";
              };
              home-manager.users.mlundquist = import ./home/mlundquist.nix;
            }
          ];
        };

        office = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit unstablePkgs inputs;
          };
          modules = [
            { nixpkgs.overlays = overlays; }
            ./hosts/office/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "hm-bak";
              home-manager.extraSpecialArgs = {
                inherit unstablePkgs inputs;
                hostname = "office";
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
              home-manager.backupFileExtension = "hm-bak";
              home-manager.extraSpecialArgs = {
                inherit unstablePkgs inputs;
                hostname = "edoras";
              };
              home-manager.users.mlundquist = import ./home/mlundquist.nix;
            }
          ];
        };
      };
    };
}
