{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.languages.terraform;
in
{
  options.languages.terraform = {
    enable = mkEnableOption "Enable terraform / terraform development tools";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      terraform
      terraform-lsp
    ];
  };
}
