variable "release_name" {
  type        = string
  description = "Used with auth_secret to create the full secret name"
  default     = ""
}

variable "namespace" {
  description = "Namespace to deploy the controller to"
}

variable "cluster_domain" {
  type        = string
  description = "Base domain for ingress"
}


variable "auth_secret_name" {
  type        = string
  default     = "controller-manager"
  description = "Used with deployment_name to create the full secret name"
}

variable "github_app_id" {
  type = string
}
variable "github_app_installation_id" {
  type = string
}

variable "github_app_private_key" {
  type = string
}

variable "github_org" {
  type = string
}

variable "github_webhook_annotations" {
  type        = map(string)
  description = "Annotations for githubWebhookServer Ingress"
  default     = {}
}

variable "github_webhook_secret_token" {
  description = "Secret token sent by GitHub webhook"
  type        = string
}

variable "controller_replica_count" {
  type        = number
  default     = 1
  description = "How many actions runner controller instances to deploy"
}