{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.development.terraform;
in
{
  options.development.terraform = {
    enable = mkEnableOption "Enable terraform / terraform development tools";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      terraform
      terraform-lsp
    ];
  };
}
