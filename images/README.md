# images 

This directory contains code for building sd card images for booting new systems. 

These images can be cross-compiled to from any architecture to the ARM (pi) arechitecture.

## build 

To build the `rpi4` image, for example:

`nix build .#images.rpi4 --log-format bar-with-logs`

This will output a `.zst` suffixed image that can be unpacked with: `nix-shell -p zstd --run "unzstd <img-name>.img.zst"`

Built images are placed in `./result`

## installation

Images should be installed directly on the PI's primary sd card and booted from there. I typically use an sd card reader 
on a laptop separate from the pi. In the following example, the sd card reader for the pi's sd card is `/dev/sdb`

Write to the pi's sd card:
`sudo dd bs=4M if=sdcard.img of=/dev/sdb conv=fsync oflag=direct status=progress`

## booting 

This is a bootable sd card image, so the pi can now be booted directly from its sd card when inserted. 

## references 

1. [https://nixos.wiki/wiki/NixOS_on_ARM](https://nixos.wiki/wiki/NixOS_on_ARM)
