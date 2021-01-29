# Modules / Tools / AWS Node Termination Handler

This deploys AWS Node Termination Handler to help gracefully remove nodes from the cluster before EC2 instances are terminated. The most common use case is to handle spot instances being removed.

[GitHub](https://github.com/aws/aws-node-termination-handler)
[Helm Chart](https://github.com/aws/eks-charts/tree/master/stable/aws-node-termination-handler)

## Notes

- The Helm chart needs to be deployed into the kube-system namespace for daemonset pods to have the needed permissions