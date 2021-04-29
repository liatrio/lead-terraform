# modules / lead / toolchain-ingress

Creates cluster wide nginx ingress controllers and SSL certificates for the LEAD toolchain.

## Jenkins
A public ingress controller for Jenkins instances create by SDM Jenkins products.
- **Class Name**: `jenkins-nginx`
- **SSL Domain**: *.jenkins.CLUSTER_DOMAIN

## Toolchain
A public ingress controller for LEAD toolchain
- **Class Name**: `toolchain-nginx`
- **SSL Domain**: *.toolchain.CLUSTER_DOMAIN

## Internal
An ingress controller bound to a load balancer in the cluster's private VPC and only accessible by traffic from the internal VPN IP range.
- **Class Name**: `internal-nginx`
- **SSL Domain**: *.internal.CLUSTER_DOMAIN
