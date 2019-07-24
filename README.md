# Overview
This repository contains the Terraform automation to manage LEAD environments.

<img src='docs/lead-architecture.png' width="100%">

## Additional Documentation

- [Istio Implementation](docs/istio-implementation.md)

## Tools
Install required tools with [Homebrew](https://brew.sh/):

```
brew bundle
```

Terraform and Terragrunt need specific version

- Terraform [0.12.5](https://releases.hashicorp.com/terraform/0.12.5/)
- Terragrunt [0.19.8](https://github.com/gruntwork-io/terragrunt/releases/download/v0.19.8/terragrunt_darwin_amd64)


## Setup
You'll need to create a `secrets/` directory with a file for each environment (e.g. liatrio-sandbox.tfvars) containing the secrets for that account.

Required Terraform variables: See [Slack Operator](https://github.com/liatrio/lead-sdm-operators/tree/master/operator-slack) to setup Slack App. 
- **artifactory_license**:
- **slack_bot_token**: Slack Bot User OAuth Token
- **slack_client_signing_secret**: Slack App Credentials Signing Secret
- **keycloak_admin_password**: Keycloak Admin Password

## Running locally
To test an environment locally, run:

```
make plugins
cd local/environment
terragrunt apply
```

To test the product locally, run:

```
cd local/product
terragrunt apply
```