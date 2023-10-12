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
  
  inputs.ess = {
    url = "github:acaloiaro/ess";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  
  inputs.di-tui = {
    url = "github:acaloiaro/di-tui";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.language-servers = {
    url = "git+https://git.sr.ht/~bwolf/language-servers.nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };


  # Raspberry pi inputs. These are locked at various revisions that are a balancing act between a confluence of bugs. 
  # The biggest of which is that the raspberry pi hardware overlays on "unstable" don't work. Some others:
  # - The latest 'home-manager' is incompatbile with older "23.05" versions of nixpkgs
  # - Just sound won't work on the mainline kernel, but video acceleration does
  # - Video acceleration works on the mainline kernel on 'unstable', but not the raspberrypi kernel, which supports audio
  inputs.nixpkgs-roampi.url = "github:nixos/nixpkgs?rev=29339c1529b2c3d650d9cf529d7318ed997c149f";
  inputs.nixos-hardware.url = "github:nixos/nixos-hardware?rev=34f96de8c9ad390d8717e3ca6260afd5f500de04";
  inputs.home-manager-roampi = {
    url = "github:nix-community/home-manager?rev=32d3e39c491e2f91152c84f8ad8b003420eab0a1";
    inputs.nixpkgs.follows = "nixpkgs-roampi";
  };

  outputs = { nixpkgs, nixpkgs-roampi, nixos-hardware, home-manager, home-manager-roampi, homeage, agenix, nur, kitty-grab, language-servers, ... }@inputs:
  let 
  	overlays = [ inputs.agenix.overlays.default inputs.nur.overlay];
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      config = { allowUnfree = true; }; 
      inherit overlays system;  
    };
  in
  {

    nixosConfigurations = {
      z1 = nixpkgs.lib.nixosSystem {
      	system = "x86_64-linux";
        inherit pkgs;
        specialArgs = {inherit inputs;};
        modules = [
          { environment.systemPackages = [ agenix.packages.x86_64-linux.default ]; }
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

      roampi = nixpkgs-roampi.lib.nixosSystem {
      	system = "aarch64-linux";
        specialArgs = {inherit inputs;};
        modules = [
          { environment.systemPackages = [ agenix.packages.aarch64-linux.default ]; }
           nur.nixosModules.nur
           agenix.nixosModules.default
          ./pi/configuration.nix
          home-manager-roampi.nixosModules.home-manager
          {
            home-manager.backupFileExtension = "backup";
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.kodi = import ./pi/kodi.nix;
            home-manager.extraSpecialArgs = {
              inherit agenix homeage;
            };
          }
        ];
      };
    };
  };
}
