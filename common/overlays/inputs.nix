{inputs, ...}: final: prev: {
  starship-jj = inputs.starship-jj.packages.${final.stdenv.hostPlatform.system}.default;
  helix = inputs.helix-flake.packages.${final.stdenv.hostPlatform.system}.default;
}
