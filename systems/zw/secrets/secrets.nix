let
  agenix = "age1ffpemt4x5l55wr42emf0f5v9lej84x7w7l44la30p329rc8cwftqach2t5";
in {
  "wireless_networks.age".publicKeys = [agenix];
  "tailscale_key.age".publicKeys = [agenix];
  "nomad_token.age".publicKeys = [agenix];
  "spotify_password.age".publicKeys = [agenix];
}
