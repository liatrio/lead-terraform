# vault-less-secure

This terraform module is a less secure version of the `vault` module within the `modules/tools` directory.

Here are the notable differences between this version and the "more secure" version:

- Offload SSL termination to an ingress controller so we don't have to pay for a separate public load balancer.
- Automatically run `vault operator init` and store the root token in a kubernetes secret
