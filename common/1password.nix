{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config._1password;
in {
  options._1password = {
    enable = mkEnableOption "1password and 1password-gui";
    user = mkOption {
      type = types.str;
      description = "the user for whom 1password is being enabled";
    };
  };

  config = mkIf cfg.enable {
    programs._1password.enable = true;
    programs._1password-gui = {
      enable = true;
      polkitPolicyOwners = [cfg.user];
    };
  };
}
