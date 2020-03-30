resource "harbor_project" "project" {
  count = var.enable_harbor ? 1 : 0
  name  = var.product_name
}

resource "harbor_robot_account" "robot" {
  count      = var.enable_harbor ? 1 : 0
  name       = "robot$imagepusher"
  project_id = harbor_project[0].project.id
  robot_account_access {
    resource = "image"
    action   = "pull"
  }

  robot_account_access {
    resource = "image"
    action   = "push"
  }

  robot_account_access {
    resource = "helm-chart"
    action   = "pull"
  }

  robot_account_access {
    resource = "helm-chart"
    action   = "push"
  }
}
