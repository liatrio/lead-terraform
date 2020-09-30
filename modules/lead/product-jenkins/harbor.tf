resource "harbor_project" "project" {
  count  = var.enable_harbor ? 1 : 0
  name   = var.product_name
  public = true
}

resource "harbor_robot_account" "robot" {
  count      = var.enable_harbor ? 1 : 0
  name       = "robot$imagepusher"
  project_id = harbor_project.project[count.index].id
  access {
    resource = "image"
    action   = "pull"
  }

  access {
    resource = "image"
    action   = "push"
  }

  access {
    resource = "helm-chart"
    action   = "pull"
  }

  access {
    resource = "helm-chart"
    action   = "push"
  }
}
