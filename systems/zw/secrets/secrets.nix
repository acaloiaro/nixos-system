let 
   agenix = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCx/tvR11RUMbYaauuHPxR3j79vm1Hxg+Y3LXR+rLgZ7N/2ulvIzLLZgVuIUbmJHDqkp9Au5zZPMZjsKbaqQ8V75wSEcyaSMbaxC9PaNDCwEHMJWaz8XPQe5IjVRE5O+4sTyh7ZBx+NMQmPcQbrNInoKuy4EjFmwTW/t0xYo/sCrC0NX0cCyeBwii2JdFXytXfxF+RMzGNXw1xfcOFJe6F7JdS/Cpf/0fe+VmNg8d0nic4Obcb/djYsRLAAC6Cvb+4i3EBZWl+9Ih9hId8bFCRKhI6TmGT2z4YUTa+v+3j/JZUh1gD5n4vRGf8QjLj9N6DrBnKcbywwqyqnLhTLgBBN35rcLdU1k3n0NorRRDCU0Lg/ejsFe3oi2FmOwNmmd8zqBNZHjJTi5Wy63EXMFwHltEY2M+hAhgWsQ5U4zuVPgv1HfD6LYPodRwhdZivwTNr2IClAiVVxR//O0WtrRXrrEM5uudj+Y30/ah7bn9Mje86UV0TqfS2tdjtMkySHL+M= adriano@z1";
  
in {
  "wireless_networks.age".publicKeys = [ agenix ];
  "tailscale_key.age".publicKeys = [ agenix ];
  "nomad_token.age".publicKeys = [ agenix ];
  "spotify_password.age".publicKeys = [ agenix ];
} 

