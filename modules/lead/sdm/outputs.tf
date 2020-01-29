output "slack_operator_in_cluster_url" {
  value = "http://operator-slack.${var.namespace}.svc.cluster.local:3000"
}
