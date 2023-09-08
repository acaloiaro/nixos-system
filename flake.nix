{
  description = "NixOS configuration";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.nur.url = "github:nix-community/NUR";

  inputs.home-manager = {
    url = "github:nix-community/home-manager/master";
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
  
  inputs.env-sample-sync = {
    url = "github:acaloiaro/env-sample-sync";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  
  inputs.di-tui = {
    url = "github:acaloiaro/di-tui";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, home-manager, homeage, agenix, nur, kitty-grab, ... }@inputs:
  let
    system = "x86_64-linux";
    overlays = [ inputs.agenix.overlays.default inputs.nur.overlay];
    pkgs = import nixpkgs {
      inherit overlays system;  
    };
  in {
    nixosConfigurations = {
      z1 = nixpkgs.lib.nixosSystem {
        inherit pkgs system;
        specialArgs = {inherit inputs;};
        modules = [
          { environment.systemPackages = [ agenix.packages.${system}.default ]; }
           nur.nixosModules.nur
           agenix.nixosModules.default
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.backupFileExtension = "backup";
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.adriano = import ./home/adriano.nix;
            home-manager.users.root = import ./home/root.nix;
            home-manager.extraSpecialArgs = {
              inherit kitty-grab agenix homeage;
            };
          }
        ];
      };
    };
  };
}
