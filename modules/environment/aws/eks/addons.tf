resource "aws_eks_addon" "coredns" {
  cluster_name      = module.eks.cluster_id
  addon_name        = "coredns"
  addon_version     = "v1.7.0-eksbuild.1"
  resolve_conflicts = "OVERWRITE"
}
