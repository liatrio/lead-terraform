bump
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

## Testing

The `tests` folder contains functional test which apply individual Terraform modules and verify the final state. The tests use [Terratest](https://terratest.gruntwork.io/) which uses golang tests to trigger Terraform and verify the outcome. The tests can be run with a local Kubernetes cluster (docker-for-desktop, minikube, microk8s, etc) or create an EKS cluster and run the tests there.

### Local tests

Make sure your current Kubernetes context points to your local cluster
```shell
make test
```

### AWS tests

The AWS tests create an EKS cluster, run the tests against the cluster and teardown the cluster. This usually takes 25 to 30 minutes. 

The tests will not interfere with other clusters in the same account and multiple tests can safely run at the same time. You should run the tests in the `sandbox` account and you must use a role with sufficient privileges (administrator).

```shell
aws-vault exec AWS_PROFILE -- make test-aws
```

The tests will attempt to teardown the cluster on failure but sometimes it is necessary to manually delete the EKS cluster and VPC.

To speed up running tests repeatedly the `--destroyCluster` flag can be set to false to skip tearing down the cluster and re-use it on subsequent tests. The `test-aws-nodestroy` make target uses this flag.
```
aws-vault exec AWS_PROFILE -- make test-aws-nodestroy
```

**Don't forget to run the test with --destroyCluster set to true to cleanup the cluster.**
```shell
aws-vault exec AWS_PROFILE -- make test-aws
```

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
