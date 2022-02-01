resource "harbor_project" "project" {
  count  = var.enable_harbor ? 1 : 0
  name   = var.product_name
  public = true
}

resource "harbor_robot_account" "robot" {
  count = var.enable_harbor ? 1 : 0
  name  = "imagepusher"
  level = "project"
  permissions {
    kind      = "project"
    namespace = harbor_project.project[count.index].name
    access {
      resource = "repository"
      action   = "pull"
    }
    access {
      resource = "repository"
      action   = "push"
    }
    access {
      resource = "artifact"
      action   = "pull"
    }
    access {
      resource = "artifact"
      action   = "push"
    }
    access {
      resource = "tag"
      action   = "create"
    }
    access {
      resource = "artifact-label"
      action   = "create"
    }
    access {
      resource = "helm-chart"
      action   = "read"
    }
    access {
      resource = "helm-chart-version"
      action   = "create"
    }
  }
}
