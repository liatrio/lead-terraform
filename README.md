# Overview
This repository contains the Terraform automation to manage LEAD environments.

<img src='docs/lead-architecture.png' width="100%">


# Dependencies

Terraform and Terragrunt need specific version

- Terraform [0.11.14](https://releases.hashicorp.com/terraform/0.11.14/)
- Terragrunt [0.18.3](https://github.com/gruntwork-io/terragrunt/releases/download/v0.18.3/terragrunt_darwin_amd64)

# Running locally

Required Terraform variables: See [Slack Operator](https://github.com/liatrio/lead-sdm-operators/tree/master/operator-slack) to setup Slack App. 
- **artifactory_license**:
- **slack_bot_token**: Slack Bot User OAuth Token
- **slack_client_signing_secret**: Slack App Credentials Signing Secret

To test an environment locally, run:

```
cd local/docker-for-desktop
terragrunt apply
```

To test the product locally, run:

```
cd local/product
terragrunt apply
```

## Running Slack operator locally

- Expose Slack operator service to localhost
  ```
  kubectl port-forward -n toolchain service/operator-slack 3000
  ```
- Expose Slack operator service to Internet
  ```
  ngrok http 3000
  ```
- Update OAuth and Event Subscriptions URLs to with ngrok hostname. See [Slack Operator](https://github.com/liatrio/lead-sdm-operators/tree/master/operator-slack).

# Prerequisite
Install required tools with [Homebrew](https://brew.sh/):

```
brew bundle
```
