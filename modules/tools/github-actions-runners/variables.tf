variable "namespace" {
  type = string
}

variable "image" {
  type        = string
  default     = ""
  description = "Runner pod Docker image"
}

variable "labels" {
  type        = list(string)
  default     = []
  description = "List of Github labels to apply to the runners"
}

variable "github_org" {
  type        = string
  description = "Github organization to register the runners to"
}

variable "github_repo" {
  type        = string
  description = "Github repository to register the runners to"
}

variable "github_runners_service_account_annotations" {
  type        = map(string)
  description = "Annotations to mount to Github Runner Service Account"
  default     = {}
}

variable "runner_autoscaler_min_replicas" {
  type    = number
  default = 0
}

variable "runner_autoscaler_max_replicas" {
  type    = number
  default = 10
}

variable "runner_autoscaler_scale_ammount" {
  type    = number
  default = 1
}

variable "runner_autoscaler_scale_duration" {
  type    = string
  default = "2m"
}
