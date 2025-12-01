{inputs, ...}: {
  nixpkgs.overlays = [
    (import ./inputs.nix {inherit inputs;})
  ];
}
