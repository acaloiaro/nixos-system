{
  description = "NixOS configuration";

  nixConfig = {
    extra-substituters = [
      "https://helix.cachix.org"
    ];
    extra-trusted-public-keys = [
      "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
    ];
  };

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.nur.url = "github:nix-community/NUR";
  inputs.home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.agenix = {
    url = "github:ryantm/agenix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.default-browser.url = "github:szympajka/nix-browser";

  inputs.homeage = {
    url = "github:jordanisaacs/homeage";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.kitty-grab = {
    url = "github:yurikhan/kitty_grab";
    flake = false;
  };

  inputs.helix-flake = {
    url = "github:helix-editor/helix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.nixos-hardware.url = "github:nixos/nixos-hardware";
  inputs.nh = {
    url = "github:viperML/nh/v4.2.0-beta2";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.btsw = {
    url = "https://flakes.adriano.fyi/btsw";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.greenhouse-nix-modules = {
    url = "git+ssh://git@github.com/grnhse/nix-modules.git";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      default-browser,
      nixpkgs,
      nixos-hardware,
      nix-darwin,
      home-manager,
      homeage,
      agenix,
      nur,
      kitty-grab,
      helix-flake,
      helix,
      greenhouse-nix-modules,
      ...
    }@inputs:
    let
      lib = nixpkgs.lib // home-manager.lib;
      overlays = [
        inputs.agenix.overlays.default
        inputs.btsw.overlays.default
        nur.overlays.default
      ];
      system = "x86_64-linux";
      darwinSystem = "aarch64-darwin";
      pkgs = import nixpkgs {
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [
            "electron-27.3.11"
          ];
        };
        inherit overlays system;
      };
      darwin-pkgs = import nixpkgs {
        system = darwinSystem;
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [
            "electron-27.3.11"
          ];
        };
        inherit overlays;
      };
    in
    {
      inherit lib;
      homeConfigurations = {
        "adriano@zw" = lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit
              kitty-grab
              agenix
              homeage
              system
              ;
            helix-flake = helix;
          };
          modules = [
            ./systems/zw/home/adriano.nix
          ];
        };
        "adriano.caloiaro@JJTH7GH17J" = lib.homeManagerConfiguration {
          pkgs = darwin-pkgs;
          extraSpecialArgs = {
            inherit
              kitty-grab
              agenix
              homeage
              darwinSystem
              greenhouse-nix-modules
              ;
            helix-flake = helix;
          };
          modules = [
            ./systems/greenhouse/home/adriano.caloiaro.nix
            inputs.greenhouse-nix-modules.home-manager
            {
              scm.authorName = "Adriano Caloiaro";
              scm.authorEmail = "adriano.caloiaro@greenhouse.io";
              scm.gpgKeyId = "FEC90D2844EA9541";
              scm.sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINCARMVM8mwZBCFsnmr/hd0atFEj9oTOATzBajLGkS9V adriano.caloiaro@JJTH7GH17J";
            }
          ];
        };
      };

      nixosConfigurations = {
        zw = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          inherit pkgs;
          specialArgs = { inherit inputs; };

          modules = [
            {
              environment.systemPackages = [
                agenix.packages.${system}.default
                inputs.nh.packages.${system}.default
              ];
            }
            nur.modules.nixos.default
            agenix.nixosModules.default
            ./systems/zw/configuration.nix
          ];
        };

        jellybee = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            { environment.systemPackages = [ agenix.packages.x86_64-linux.default ]; }
            nur.modules.nixos.default
            agenix.nixosModules.default
            ./systems/jellybee/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.backupFileExtension = "backup";
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                inherit agenix homeage;
              };
            }
          ];
        };

        homebee = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            { environment.systemPackages = [ agenix.packages.x86_64-linux.default ]; }
            nur.modules.nixos.default
            agenix.nixosModules.default
            ./systems/homebee/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.backupFileExtension = "backup";
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                inherit agenix homeage;
              };
            }
          ];
        };
      };

      darwinConfigurations.JJTH7GH17J = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit inputs; };

        modules = [
          default-browser.darwinModules.default-browser
          ./systems/greenhouse/configuration.nix
          inputs.greenhouse-nix-modules.nix-darwin
          inputs.home-manager.darwinModules.home-manager
          {
            home-manager.backupFileExtension = "backup";
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit nix-darwin;
            };
          }
        ];
      };

    };
}
