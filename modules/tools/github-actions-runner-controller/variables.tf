variable deployment_name {
  type = string
  default = "actions-runner-controller"
  description = "Used with auth_secret to create the full secret name"
}

variable namespace {
  description = "Namespace to deploy the controller to"
}

variable cluster_domain {
  type = string
  description = "Base domain for ingress"
}


variable auth_secret_name {
  type = string
  default = "controller-manager"
  description = "Used with deployment_name to create the full secret name"
}

variable github_app_id {
  type = string
}
variable github_app_installation_id {
  type = string
}

variable github_app_private_key {
  type = string
}

variable github_org {
  type = string
}

variable controller_replica_count {
  type = number
  default = 1
  description = "How many actions runner controller instances to deploy"
}


variable runner_autoscaling_enabled {
  type = bool
  default = false
}

variable runner_autoscaling_min_replicas {
  type = number
  default = 1
}

variable runner_autoscaling_max_replicas {
  type = number
  default = 10
}

variable runner_autoscaling_cpu_util {
  type = number
  default = 80
  description = "CPU utilization percent at which to trigger a scale up"
}
