{
  description = "NixOS configuration";

  inputs.determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.nur.url = "github:nix-community/NUR";
  inputs.home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.lsp-mux.url = "sourcehut:~jcmuller/lsp-mux";
  inputs.disko = {
    url = "github:nix-community/disko";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.agenix = {
    url = "github:ryantm/agenix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.agenix-rekey = {
    url = "github:oddlama/agenix-rekey";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.kitty-grab = {
    url = "github:yurikhan/kitty_grab";
    flake = false;
  };

  inputs.helix-flake = {
    url = "github:acaloiaro/helix/patchy";
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

  inputs.starship-jj = {
    url = "gitlab:lanastara_foss/starship-jj";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.roam-location = {
    url = "github:acaloiaro/roam-location/starlink-location";
    flake = false;
  };

  outputs = {
    self,
    nixpkgs,
    nixos-hardware,
    home-manager,
    agenix,
    agenix-rekey,
    nur,
    kitty-grab,
    helix,
    ...
  } @ inputs: let
    lib = nixpkgs.lib // home-manager.lib;
    overlays = [
      inputs.agenix-rekey.overlays.default
      inputs.btsw.overlays.default
      inputs.lsp-mux.overlays.default
      nur.overlays.default
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

    # Wrapper to handle the dynamic master key
    mkRekeyApp = system: pkgs: let
      rekeyPackage = inputs.agenix-rekey.packages.${system}.default;
    in {
      type = "app";
      program = "${pkgs.writeShellScript "rekey-wrapper" ''
        # Create the file expected by the config
        # We use /dev/shm (RAM-based tmpfs) to ensure the key never touches disk
        REPO_ROOT=$(git rev-parse --show-toplevel)
        MASTER_KEY_FILE="/dev/shm/agenix-master-$$.key"

        # Cleanup on exit
        trap 'rm -f "$MASTER_KEY_FILE"' EXIT

        # Get the master key from gopass and write to RAM only
        echo "Retrieving master key from gopass..."
        ${pkgs.gopass}/bin/gopass show -o systems/age.master > "$MASTER_KEY_FILE"
        chmod 600 "$MASTER_KEY_FILE"

        # Run the actual rekey command from the repo root with symlink
        cd "$REPO_ROOT"
        ln -sf "$MASTER_KEY_FILE" master.key
        trap 'rm -f "$MASTER_KEY_FILE" master.key' EXIT
        ${rekeyPackage}/bin/agenix rekey "$@"
      ''}";
    };
  in {
    inherit lib;
    apps.${system}.rekey = mkRekeyApp system pkgs;
    homeConfigurations = {
      "adriano@zw" = lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit
            agenix
            inputs
            kitty-grab
            system
            ;
        };
        modules = [
          agenix.homeManagerModules.default
          agenix-rekey.homeManagerModules.default
          inputs.lsp-mux.homeManagerModules.default
          ./common/rekey.nix
          (import ./common/overlays)
          ./systems/zw/home/adriano.nix
          ./common/home-manager/code
          {
            code = {
              jujutsu.enable = true;
              git.enable = true;
              user = {
                name = "Adriano Caloiaro";
                email = "code@adriano.fyi";
                gpg-key-id = "8E8D7473B70F3860341DD171FEC90D2844EA9541";
                ssh-public-key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQD1LwyUmY8yaaIfPKn9aUIsbm8NkcLvx8MOILtKubMxOvnJ+ZkOQnqve/KE+VNdvOzlZgnnLA24ZAeM5fD8n/WFVjDRsKqXVAfZOIygm2/P1RzEK5+AoVOeIC25DhizNGJ0pE8F4aSVTmTtOq5kOf1bTSuVhv3p/k6ZusrzBI2HOEOUg/sfs3Q1L7wHDHTA5qxqYACLebGocq0KqWPW4GTJ67XEMiNIENBh4EEEDTaeQZjRomeeR0ssDlrNAabf+vp+dxEtyHXS9dPznCFUIh7KyCx1oKLBl/O3B2NuVycXdo2yGpPGF6iKC6HW6lBHkYWfmgunQ4NOZWpbFFF0nT7K/kbFjmQKn3h7xuH3wXqs+iGXlDCQ1c/7YKarrD/JOsyWN/qHj9nto5QE40GZZRqhO1i16jCgMTyk0VLwZ5Eq6+zAKBKBQ2t/aFov4i05LuM3geg3LO4BoyQnP/ikuDb4ENRb1+wlJp9kCk2YKZeLwcgBXYg9xkXpX5ZnQl9E26s=";
              };
            };
          }
        ];
      };
    };

    nixosConfigurations = {
      zw = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        inherit pkgs;
        specialArgs = {inherit inputs;};

        modules = [
          inputs.determinate.nixosModules.default
          (import ./common/overlays)
          {
            environment.systemPackages = [
              inputs.nh.packages.${system}.default
            ];
          }
          nur.modules.nixos.default
          agenix.nixosModules.default
          agenix-rekey.nixosModules.default
          ./common/rekey.nix
          ./systems/zw/configuration.nix
        ];
      };

      jellybee = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules = [
          {environment.systemPackages = [];}
          nur.modules.nixos.default
          agenix.nixosModules.default
          agenix-rekey.nixosModules.default
          ./common/rekey.nix
          inputs.disko.nixosModules.default
          ./systems/jellybee/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.backupFileExtension = "backup";
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit agenix;
            };
          }
        ];
      };

      homebee = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules = [
          {environment.systemPackages = [];}
          nur.modules.nixos.default
          agenix.nixosModules.default
          agenix-rekey.nixosModules.default
          ./common/rekey.nix
          ./systems/homebee/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.backupFileExtension = "backup";
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit agenix;
            };
          }
        ];
      };
    };

    agenix-rekey = inputs.agenix-rekey.configure {
      userFlake = self;
      nixosConfigurations = self.nixosConfigurations;
      homeConfigurations = self.homeConfigurations;
    };
  };
}
