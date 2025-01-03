{
  description = "NixOS configuration";

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

  inputs.di-tui = {
    url = "github:acaloiaro/di-tui/v1.11.0";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.language-servers = {
    url = "git+https://git.sr.ht/~bwolf/language-servers.nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.helix-master = {
    url = "github:helix-editor/helix/master";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.nixos-hardware.url = "github:nixos/nixos-hardware";
  inputs.nh = {
    url = "github:viperML/nh";
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
    helix-master,
    ...
  } @ inputs: let
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
    nixosConfigurations = {
      z1 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        inherit pkgs;
        specialArgs = {inherit inputs;};
        modules = [
          {environment.systemPackages = [agenix.packages.x86_64-linux.default];}
          nur.modules.nixos.default
          agenix.nixosModules.default
          ./systems/z1/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.backupFileExtension = "backup";
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.adriano = import ./systems/z1/home/adriano.nix;
            home-manager.users.root = import ./systems/z1/home/root.nix;
            home-manager.extraSpecialArgs = {
              inherit kitty-grab agenix homeage helix-master;
            };
          }
        ];
      };

      zw = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        inherit pkgs;
        specialArgs = {inherit inputs;};

        modules = [
          {environment.systemPackages = [agenix.packages.${system}.default inputs.nh.packages.${system}.default];}
          nur.modules.nixos.default
          agenix.nixosModules.default
          ./systems/zw/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.backupFileExtension = "backup";
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.adriano = import ./systems/zw/home/adriano.nix;
            home-manager.users.root = import ./systems/zw/home/root.nix;
            home-manager.extraSpecialArgs = {
              inherit kitty-grab agenix homeage helix-master;
            };
          }
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
