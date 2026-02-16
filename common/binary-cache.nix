{lib, ...}: {
  nix.settings = {
    extra-substituters = [
      "http://jellybee.bison-lizard.ts.net:5676"
      "https://colmena.cachix.org"
      "https://helix.cachix.org"
      "https://jj.cachix.org"
      "https://nixpkgs-ruby.cachix.org"
    ];
    extra-trusted-public-keys = [
      "jellybee:fvMOHRT+wUeGzyANNB5CEFVeHK7uzwy7tAG5TaS0zmM="
      "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg="
      "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
      "jj.cachix.org-1:rOXYMWIM8CAjR0M3kifWXVoDXVriTPz+gX5oSdJe2Is="
      "nixpkgs-ruby.cachix.org-1:vrcdi50fTolOxWCZZkw0jakOnUI1T19oYJ+PRYdK4SM="
    ];
  };
}
