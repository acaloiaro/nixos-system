# About 

This directory contains encrypted secrets. 

The private keys for the public keys listed in `secrets.nix` must be available on the system.

NixOS does not handle private keys with pass phrases well. It is recommended that one generate keys without passphrases, e.g. 

> ssh-keygen -t rsa -b 4096 -C "code@adriano.fyi" -f ~/.ssh/id_rsa_<system_name> -P "" 

Once keys have been generated for the new system, the private key needs to be transferred to the new system: `/root/.ssh/id_rsa`

## Dependencies

Adding keys and re-keying require `agenix` to be installed. On a nix system, install with `nix-shell -p agenix`.

## Re-keying 

Re-keying must be done when new keys are added.

> agenix -r 

## Adding secrets 

To add new secrets, edit `secrets.nix` and then edit this contents of the new secrets with:

> agenix -e <SECRET NAME>

Don't forget to commit new secrets to git. 
