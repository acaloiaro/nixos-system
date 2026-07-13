final: prev: {
  glow = prev.glow.overrideAttrs (oldAttrs: {
    src = final.fetchFromGitHub {
      owner = "acaloiaro";
      repo = "glow";
      rev = "master";
      hash = "sha256-eCkGRx/uEfnytkbHsaoYro4Cn3/b43BalRjz9BOxOXc=";
    };

    vendorHash = "sha256-o5Z2ABRw6v4wFXp+KxgdKQn5/Lk5LG73VTiDOA/kBIs=";
  });
}
