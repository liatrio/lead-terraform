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

```shell
artifactory_license          = "Artifactory License (ask in slack)"
slack_bot_token              = "Slack Bot User OAuth Token"
slack_client_signing_secret  = "Slack App Credentials Signing Secret"
keycloak_admin_password      = "Keycloak Admin Password"
prometheus_slack_channel     = "Some Slack Channel"
prometheus_slack_webhook_url = "Some Slack Webhook Url"
```

See instructions for [creating slack app](https://github.com/liatrio/lead-sdm-operators/tree/master/operator-slack)

## Running locally

Follow _Setup_ instructions above and store secrets in `secrets/docker-for-desktop.tfvars`

Add these additional dependency versions in `local/environment/local.auto.tfvars`

```shell
sdm_version                  = "v2.0.0"
dashboard_version            = "v2.0.0"
builder_images_version       = "v2.0.0"
jenkins_image_version        = "v2.0.0"
```

You can find up to date versions in the lead-environments repo by looking at what is deployed to [production](https://github.com/liatrio/lead-environments/blob/master/aws/liatrio-prod/terragrunt.hcl) or [sandbox](https://github.com/liatrio/lead-environments/blob/master/aws/liatrio-sandbox/terragrunt.hcl) environments.

To test an environment locally, run:

```shell
# Setup keycloak plugin
make plugins
```

```shell
cd local/environment

# Validate a 'stack'
terragrunt validate

# Apply a 'stack' 
terragrunt apply
```

To test the product locally, run:

```shell
cd local/product

# Apply a 'stack' 
terragrunt apply
```
