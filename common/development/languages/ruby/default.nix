{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.languages.ruby;
in
{
  options.languages.ruby = {
    enable = mkEnableOption "Enable Ruby development tools";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      ruby
      rubyPackages.pry
      solargraph
    ];

    home.activation.installRubyGems = ''
      # tty-prompt is used by the "aws shim": https://greenhouseio.atlassian.net/wiki/spaces/SE/pages/710803589/2.+Secure+Credentials+Connections#AWS-CLI%2C-AWS-Shim
      ${getExe' pkgs.ruby "gem"} install --user-install --no-document tty-prompt 
    '';
  };
}
