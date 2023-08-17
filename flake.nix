{
   description = "NixOS configuration";
   inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
   inputs.home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
   };

   inputs.agenix = {
     url = "github:ryantm/agenix";
     inputs.nixpkgs.follows = "nixpkgs";
   };
  
  inputs.nur.url = "github:nix-community/NUR";
  inputs.kitty-grab = {
    url = "github:yurikhan/kitty_grab";
    flake = false;
  };
  
  outputs = { nixpkgs, home-manager, agenix, nur, kitty-grab, ... }@inputs:
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
        
        modules = [
          { environment.systemPackages = [ agenix.packages.${system}.default ]; }
           nur.nixosModules.nur
           agenix.nixosModules.default
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.adriano = import ./home/adriano.nix;
            home-manager.users.root = import ./home/root.nix;
            home-manager.extraSpecialArgs = {
              inherit kitty-grab;
            };
          }
        ];
      };
    };
  };
}
