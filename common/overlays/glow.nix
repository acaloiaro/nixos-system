final: prev: {
  glow = prev.glow.overrideAttrs (oldAttrs: {
    src = final.fetchFromGitHub {
      owner = "acaloiaro";
      repo = "glow";
      rev = "master";
      hash = "sha256-JKuodO0ZEzhxf5InqR1+e0PqXYwALc8I20s7uCYJwjA=";
    };

    vendorHash = "sha256-rICfbrAh9ow2yLsXtx3y02LMR9oxDQuk20WrMX3P1xM=";
  });
}
