{ config, pkgs, lib, homeage,  ... }:
{
  imports = [
    #homeage.homeManagerModules.homeage
  ];  

  programs.home-manager = {
    enable = true;
  };
  home = {
    stateVersion = "23.05";
    sessionVariables = {};

    file = {
      ".kodi/userdata/keymaps/kodi_remote_keymaps.xml".source = ./kodi_remote_keymaps.xml;
    };

    services.syncthing = {
      enable = true;
      tray = true;
    };
  };
}
