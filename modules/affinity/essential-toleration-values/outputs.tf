output "values" {
  value = templatefile("${path.module}/essential-toleration.tpl", {
    essential_taint_key = var.essential_taint_key
    node_affinity_mode = var.node_affinity_mode
  })
}
