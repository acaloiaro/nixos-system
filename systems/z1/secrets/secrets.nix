let 
   z1 = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC5iTLEmZV3/JZ2diPSgVtgBo9LV1XLTuDVktnaXA+xP6ompz5C9OQTXgTdERZB9hZB7M/cRVNaXF1Ug1KGFVEb/8Axwvu7jlxbY9qcnYD6yXLtOT/g9LPwdOtgKulY2A6qruhtZvZD9DIv1OHrt+ydoPFGU8pYLVeeqi7PxZoksirDfx3pe3EHh0dmG9ctsD0VURW1KoW0TNqA1Eh3CFZ77VpyEDkQajxxLW6j3aobI5mw42fIAL2kfYy9Izgk+h1CNacVUADWzW5PlHxj7896oQ0u8OqJs3xAVcxHd4RsYgK66Z9q70juFPWsluufsINJIPyQM2Rc7Yn407wRQYWZDZ9/lplB3Qrsh6d61XQ8pU1iHrlM0xrQGyPwYg+wDssL21za9haTEtr+0qVM58o5Bveg7aWSAWvsO4WK5IG5pRIu/hkus1j1JEWDhqBqA3s7Rwov5HXDUssitPcGOH4V4VWaM83DaSpN0ZH5rS63f2Z+lkHyunksyitlWvluzEzIOEuQPv+72le5TUIPSA26t2OL23goN4xoQmCQP7Jcg6xSM0gYi447647TMTArxEDVbc7/zIY7wAX76VYXDlqAxeJ19w4PBNNgKlwcRJZhuqaM/lOLRiAfD3C3UiUOwjk86LzwcMe5LGtldg/ZUG9+dhG0fibCt52lVnDLvyBlpw== code@adriano.fyi";
   agenix = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCx/tvR11RUMbYaauuHPxR3j79vm1Hxg+Y3LXR+rLgZ7N/2ulvIzLLZgVuIUbmJHDqkp9Au5zZPMZjsKbaqQ8V75wSEcyaSMbaxC9PaNDCwEHMJWaz8XPQe5IjVRE5O+4sTyh7ZBx+NMQmPcQbrNInoKuy4EjFmwTW/t0xYo/sCrC0NX0cCyeBwii2JdFXytXfxF+RMzGNXw1xfcOFJe6F7JdS/Cpf/0fe+VmNg8d0nic4Obcb/djYsRLAAC6Cvb+4i3EBZWl+9Ih9hId8bFCRKhI6TmGT2z4YUTa+v+3j/JZUh1gD5n4vRGf8QjLj9N6DrBnKcbywwqyqnLhTLgBBN35rcLdU1k3n0NorRRDCU0Lg/ejsFe3oi2FmOwNmmd8zqBNZHjJTi5Wy63EXMFwHltEY2M+hAhgWsQ5U4zuVPgv1HfD6LYPodRwhdZivwTNr2IClAiVVxR//O0WtrRXrrEM5uudj+Y30/ah7bn9Mje86UV0TqfS2tdjtMkySHL+M= adriano@z1";
  
in {
  "wireless_networks.age".publicKeys = [ agenix z1 ];
  "tailscale_key.age".publicKeys = [ agenix z1 ];
  "nomad_token.age".publicKeys = [ agenix ];
  "spotify_password.age".publicKeys = [ agenix ];
} 

