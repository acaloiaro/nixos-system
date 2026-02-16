{
  config,
  lib,
  ...
}: let
  privateSubstituter = "http://jellybee.bison-lizard.ts.net:5676";
  privateSubstituterKey = "jellybee:fvMOHRT+wUeGzyANNB5CEFVeHK7uzwy7tAG5TaS0zmM=";
in {
  options = {
    substituters.private.enable = lib.mkEnableOption "Enable the private substituter";
  };

  config = {
    nix.settings = {
      extra-substituters =
        [
          "https://colmena.cachix.org"
          "https://devenv.cachix.org"
          "https://helix.cachix.org"
          "https://jj.cachix.org"
          "https://nixpkgs-ruby.cachix.org"
        ]
        ++ lib.optional config.substituters.private.enable privateSubstituter;
      extra-trusted-public-keys =
        [
          "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg="
          "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
          "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
          "jj.cachix.org-1:rOXYMWIM8CAjR0M3kifWXVoDXVriTPz+gX5oSdJe2Is="
          "nixpkgs-ruby.cachix.org-1:vrcdi50fTolOxWCZZkw0jakOnUI1T19oYJ+PRYdK4SM="
        ]
        ++ lib.optional config.substituters.private.enable privateSubstituterKey;
    };
  };
}
