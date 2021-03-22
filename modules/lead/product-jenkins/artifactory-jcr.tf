resource "random_password" "robot_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "artifactory_user" "robot" {
  count      = var.enable_artifactory ? 1 : 0
  name       = "robot-${var.product_name}" 
  email      = "robot-${var.product_name}@liatrio.com"
  password   = data.random_password.robot_password.result
}
