variable "service_account_name" {
  type = string
}

variable "cluster_role_name" {
  type = string
}

variable "rules" {
  type = list(object({
    api_groups = [],
    resources  = [],
    verbs      = []
  }))
}
