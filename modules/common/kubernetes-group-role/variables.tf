variable "group_name" {
  type = string
}

variable "role_name" {
  type = string
}

variable "namespace" {
  type = string
}

variable "rules" {
  type = list(object({
    api_groups = list(string),
    resources  = list(string),
    verbs      = list(string)
  }))
}
