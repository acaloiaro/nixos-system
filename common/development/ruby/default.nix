{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.development.ruby;
in
{
  options.development.ruby = {
    enable = mkEnableOption "Enable Ruby development tools";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      ruby
      rubyPackages.pry
      solargraph
    ];
    
  home.activation.installRubyGems = ''
    ${getExe' pkgs.ruby "gem"} install --user-install --no-document tty-prompt 
  '';
  };
}
