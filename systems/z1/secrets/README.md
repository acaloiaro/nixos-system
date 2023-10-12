# About 

This directory contains encrypted secrets. 

The private keys for the public keys listed in `secrets.nix` must be available on any systems that use the `z1` flake at the top-level of this repository.

NixOS does not handle private keys with pass phrases well. It is recommended that one generate keys without passphrases, e.g. 

> ssh-keygen -t rsa -b 4096 -C "code@adriano.fyi" -f ~/.ssh/id_rsa_nixos

## Dependencies

Adding keys and re-keying require `agenix` to be installed. On a nix system, install with `nix-env -i agenix`.

## Re-keying 

Re-keying must be done when new keys are added.

> agenix -r 

## Adding secrets 

To add new secrets, edit `secrets.nix` and then edit this contents of the new secrets with:

> agenix -e <SECRET NAME>

Don't forget to commit new secrets to git. 