output "values" {
  value = templatefile("${path.module}/essential-toleration.tpl", {
    essential_taint_key = var.essential_taint_key
  })
}
