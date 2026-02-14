{lib, ...}: {
  nix.settings = {
    substituters = lib.mkBefore [
      "http://jellybee.bison-lizard.ts.net:5676"
    ];
    trusted-public-keys = [
      "jellybee:fvMOHRT+wUeGzyANNB5CEFVeHK7uzwy7tAG5TaS0zmM="
    ];
  };
}
