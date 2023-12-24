{ agenix, config, lib, pkgs, inputs, homeage, ... }: 
{
  nixpkgs.config.allowUnsupportedSystem = true;
  nixpkgs.hostPlatform.system = "aarch64-linux";
  nixpkgs.buildPlatform.system = "x86_64-linux"; #If you build on x86 other wise changes this.
  # ... extra configs as above
  sdImage.compressImage = false;

  services.openssh.enable = true;
  networking.hostName = "homepi"; # Define your hostname.
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.wireless.networks = {
    "Home5536" = {
      psk = "3216240371";
    };
  };

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
      '';
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };


  environment.systemPackages = with pkgs; [
    inputs.agenix
    git 
    tailscale
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
  ];

  users.mutableUsers = true;
  users = {
    users.pi = {
      isNormalUser = true;
      initialPassword = "raspberrypi";
      extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
      openssh.authorizedKeys.keys = [
         "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQD1LwyUmY8yaaIfPKn9aUIsbm8NkcLvx8MOILtKubMxOvnJ+ZkOQnqve/KE+VNdvOzlZgnnLA24ZAeM5fD8n/WFVjDRsKqXVAfZOIygm2/P1RzEK5+AoVOeIC25DhizNGJ0pE8F4aSVTmTtOq5kOf1bTSuVhv3p/k6ZusrzBI2HOEOUg/sfs3Q1L7wHDHTA5qxqYACLebGocq0KqWPW4GTJ67XEMiNIENBh4EEEDTaeQZjRomeeR0ssDlrNAabf+vp+dxEtyHXS9dPznCFUIh7KyCx1oKLBl/O3B2NuVycXdo2yGpPGF6iKC6HW6lBHkYWfmgunQ4NOZWpbFFF0nT7K/kbFjmQKn3h7xuH3wXqs+iGXlDCQ1c/7YKarrD/JOsyWN/qHj9nto5QE40GZZRqhO1i16jCgMTyk0VLwZ5Eq6+zAKBKBQ2t/aFov4i05LuM3geg3LO4BoyQnP/ikuDb4ENRb1+wlJp9kCk2YKZeLwcgBXYg9xkXpX5ZnQl9E26s= adriano@zenity"];
      packages = with pkgs; [
      ];
    };
  };

  system.stateVersion = "24.05";
}
