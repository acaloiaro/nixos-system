final: prev: {
  glow = prev.glow.overrideAttrs (oldAttrs: {
    src = final.fetchFromGitHub {
      owner = "acaloiaro";
      repo = "glow";
      rev = "master";
      hash = "sha256-my2lKbXmUysnxC96MtnjEb216362vzXu2ZBMeKvn9+c=";
    };

    vendorHash = "sha256-rICfbrAh9ow2yLsXtx3y02LMR9oxDQuk20WrMX3P1xM=";
  });
}
