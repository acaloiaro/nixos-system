{
  description = "Build image";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.agenix = {
     url = "github:ryantm/agenix";
     inputs.nixpkgs.follows = "nixpkgs";
   };
  inputs.homeage = {
    url = "github:jordanisaacs/homeage";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.home-manager = {
    url = "github:nix-community/home-manager/master";
    inputs.nixpkgs.follows = "nixpkgs";
   };

  inputs.nixos-hardware.url = "github:nixos/nixos-hardware?rev=34f96de8c9ad390d8717e3ca6260afd5f500de04";

  outputs = { self, agenix, homeage, home-manager, nixos-hardware, nixpkgs }@inputs: 
  rec {
    nixosConfigurations.rpi4 = nixpkgs.lib.nixosSystem {
    	system = "aarch64-linux";
      specialArgs = {inherit inputs;};
      modules = [
        "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
        # { environment.systemPackages = [ agenix.packages.aarch64-linux.default ]; }
         agenix.nixosModules.default

        # Below block enable cross-compiling from x86 to aarch
        {
          nixpkgs.config.allowUnsupportedSystem = true;
          nixpkgs.hostPlatform.system = "aarch64-linux";
          nixpkgs.buildPlatform.system = "x86_64-linux"; #If you build on x86 other wise changes this.
        }
        ./systems/homepi/default.nix
      ];
    };

    # Enable reating an sd card image of this rpi4
    images.rpi4 = nixosConfigurations.rpi4.config.system.build.sdImage;
  };
}
