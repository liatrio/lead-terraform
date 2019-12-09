# Overview
This repository contains the Terraform automation to manage LEAD environments.

![](./docs/lead-architecture.png)

## Additional Documentation

- [Istio Implementation](docs/istio-implementation.md)

## Tools
Install required tools with [Homebrew](https://brew.sh/):

```
brew bundle
```

## Setup
You'll need to create a `secrets/` directory with a file for each environment (e.g. liatrio-sandbox.tfvars) containing the secrets for that account.

Required Terraform variables: See [Slack Operator](https://github.com/liatrio/lead-sdm-operators/tree/master/operator-slack) to setup Slack App.
- **artifactory_license**:
- **slack_bot_token**: Slack Bot User OAuth Token
- **slack_client_signing_secret**: Slack App Credentials Signing Secret
- **keycloak_admin_password**: Keycloak Admin Password

## Running locally
To test an environment locally, run:

Set dependency versions in `local/environment.local.auto.tfvars`. 
```
sdm_version             = "v0.0.1-1-a1b2c3d4"
builder_images_version  = "v0.0.1-1-a1b2c3d4"
jenkins_image_version   = "v0.0.1-1-a1b2c3d4"
dashboard_version       = "v0.0.1-1-a1b2c3d4"
```
Check the [lead-environments](https://github.com/liatrio/lead-environments) repo for up to date versions.

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
