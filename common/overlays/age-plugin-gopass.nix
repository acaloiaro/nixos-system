{inputs, ...}: final: prev: {
  age-plugin-gopass = inputs.age-plugin-gopass.packages.${final.stdenv.hostPlatform.system}.default;
}
