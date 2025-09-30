{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.greenhouse;
in
{
  imports = [
    ../development/go
    ../development/ruby
    ../development/terraform
    ../development/tooling
  ]
  ;
  options.greenhouse = {
    enable = mkEnableOption "Greenhouse module installs developers tools";
    languages = {
      go.enable = mkEnableOption {
        type = types.bool;
        default = false;
        description = "enable go development tools";
      };
      ruby.enable = mkEnableOption {
        type = types.bool;
        default = true;
        description = "enable Ruby development tools";
      };
      terraform.enable = mkEnableOption {
        type = types.bool;
        default = false;
        description = "enable terraform development tools";
      };
    };
    tooling = mkOption {
      type = types.anything; # TODO: This should be a proper submodule type
      default = {};
      description = "";
    };
  };
  config = mkIf cfg.enable {
    development = {
      go = cfg.languages.go;
      ruby = cfg.languages.ruby;
      terraform = cfg.languages.terraform;
      tooling = cfg.tooling;
    };
  };
}
