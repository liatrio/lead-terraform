# Overview
This repository contains the Terraform automation to manage LEAD environments.

<img src='docs/lead-architecture.png' width="100%">

# Running locally
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

# Prerequisite
Install required tools with [Homebrew](https://brew.sh/):

```
brew bundle
```