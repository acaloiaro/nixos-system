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

  inputs.homeage = {
    url = "github:jordanisaacs/homeage";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.kitty-grab = {
    url = "github:yurikhan/kitty_grab";
    flake = false;
  };

  inputs.ess = {
    url = "github:acaloiaro/ess/v2.14.1";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.sils = {
    url = "sourcehut:~jcmuller/simple-inserts-language-server/v0.3.3";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.language-servers = {
    url = "git+https://git.sr.ht/~bwolf/language-servers.nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.helix-flake = {
    url = "github:helix-editor/helix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.nixos-hardware.url = "github:nixos/nixos-hardware";
  inputs.nh = {
    url = "github:viperML/nh";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.lix-module = {
    url = "https://git.lix.systems/lix-project/nixos-module/archive/2.92.0.tar.gz";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    nixpkgs,
    nixos-hardware,
    home-manager,
    homeage,
    agenix,
    nur,
    kitty-grab,
    language-servers,
    sils,
    helix-flake,
    lix-module,
    helix,
    ...
  } @ inputs: let
    lib = nixpkgs.lib // home-manager.lib;
    overlays = [
      inputs.agenix.overlays.default
      nur.overlays.default
      (
        final: prev: {
          # logseq = prev.logseq.override {
          #   electron = prev.electron_27;
          # };
        }
      )
    ];
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      config = {
        allowUnfree = true;
        permittedInsecurePackages = [
          "electron-27.3.11"
        ];
      };
      inherit overlays system;
    };
  in {
    inherit lib;
    homeConfigurations = {
      "adriano@zw" = lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit kitty-grab agenix homeage system;
          helix-flake = helix;
        };
        modules = [
          ./systems/zw/home/adriano.nix
        ];
      };
    };

    nixosConfigurations = {
      zw = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        inherit pkgs;
        specialArgs = {inherit inputs;};

        modules = [
          {environment.systemPackages = [agenix.packages.${system}.default inputs.nh.packages.${system}.default];}
          nur.modules.nixos.default
          agenix.nixosModules.default
          ./systems/zw/configuration.nix
          lix-module.nixosModules.default
        ];
      };

      jellybee = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules = [
          {environment.systemPackages = [agenix.packages.x86_64-linux.default];}
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
        specialArgs = {inherit inputs;};
        modules = [
          {environment.systemPackages = [agenix.packages.x86_64-linux.default];}
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
  };
}
