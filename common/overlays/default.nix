{inputs, ...}: {
  nixpkgs.overlays = [
    (import ./inputs.nix {inherit inputs;})
    (import ./go-jira.nix)
    (import ./glow.nix)
  ];
}
