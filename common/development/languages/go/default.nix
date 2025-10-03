{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.languages.go;
in
{
  options.languages.go.enable = mkEnableOption "Enable go development tools";
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      go_1_24
      gopls
    ];
    home.sessionVariables = mkIf cfg.enable {
      "GO111MODULE" = "on";
      "PATH" = "$PATH:$HOME/go/bin";
    };
  };
}
