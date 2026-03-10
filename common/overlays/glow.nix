final: prev: {
  glow = prev.glow.overrideAttrs (oldAttrs: {
    src = final.fetchFromGitHub {
      owner = "acaloiaro";
      repo = "glow";
      rev = "master";
      hash = "sha256-I5kgoYqAuyPfVKdgaovrP3W2/DbcalQCjJVX+W3J/ac=";
    };

    vendorHash = "sha256-rICfbrAh9ow2yLsXtx3y02LMR9oxDQuk20WrMX3P1xM=";
  });
}
