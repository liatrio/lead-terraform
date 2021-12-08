resource "aws_eks_addon" "coredns" {
  cluster_name      = "lead"
  addon_name        = "coredns"
  addon_version     = "v1.7.0-eksbuild.1"
  resolve_conflicts = "OVERWRITE"
}
