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

This project uses `golang` to execute tests. You will need to clone this project into a `go/src/` directory. The `GOPATH` should then be set to `<your_top_level_dir>/go`.

```bash
make -p go/src
cd go/src
git clone https://github.com/liatrio/lead-terraform.git
```

The directory structure should look like this:

```bash
go
└── src
    ├── lead-environments
    ├── lead-terraform
```

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
