{inputs, ...}: {
  nixpkgs.overlays = [
    (import ./inputs.nix {inherit inputs;})
    (import ./claude-code)
    (import ./go-jira.nix)
    (import ./glow.nix)
    (import ./nyxt.nix)
    (import ./age-plugin-gopass.nix {inherit inputs;})
  ];
}
