{ config, pkgs, lib, homeage,  ... }:
{
  imports = [
    #homeage.homeManagerModules.homeage
  ];  

  xsession = {
    enable = true;
    initExtra = ''
      xset s off -display :0.0
      xset s noblank -display :0.0
      xset -dpms -dispaly :0.0
    '';
  }; 

  programs.home-manager = {
    enable = true;
  };
  home = {
    stateVersion = "23.05";
    sessionVariables = {};

    file = {
      ".kodi/userdata/keymaps/kodi_remote_keymaps.xml".source = ./kodi_remote_keymaps.xml;
    };

   
  };
}
