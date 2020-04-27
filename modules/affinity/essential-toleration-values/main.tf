data "template_file" "essential_toleration" {
  template = file("${path.module}/essential-toleration.tpl")
  vars     = {
    essential_taint_key = var.essential_taint_key
  }
}
