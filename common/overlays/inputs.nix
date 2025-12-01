{inputs, ...}: final: prev: {
  starship-jj = inputs.starship-jj.packages.${final.stdenv.hostPlatform.system}.default;
}
