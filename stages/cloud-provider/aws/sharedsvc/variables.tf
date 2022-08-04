variable "cluster_version" {}

variable "cluster_addons" {
  description = "EKS addons to install to the cluster"
  type        = map(string)
  default     = {}
}

variable "cluster_name" {}

variable "region" {
  default = "us-east-1"
}

variable "key_name" {
  default = ""
}

variable "preemptible_instance_types" {
  type = list(any)
  default = [
    "m5.xlarge",
    "c5.xlarge",
    "m4.xlarge",
    "c4.xlarge",
    "t3.xlarge",
    "r5.xlarge"
  ]
}

variable "preemptible_asg_min_size" {
  default = "1"
}

variable "preemptible_asg_desired_capacity" {
  default = "1"
}

variable "preemptible_asg_max_size" {
  default = "5"
}

variable "essential_instance_type" {
  default = "t3.large"
}

variable "essential_asg_min_size" {
  default = "1"
}

variable "essential_asg_desired_capacity" {
  default = "1"
}

variable "essential_asg_max_size" {
  default = "5"
}

variable "essential_taint_key" {
  default = "EssentialOnly"
}

variable "vpc_name" {}

variable "additional_mapped_roles" {
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}

variable "vault_dynamodb_table_name" {}
variable "system_namespace" {}

variable "cluster_domain" {
  default = "services.liatr.io"
}
variable "internal_cluster_domain" {
  default = "internal.services.liatr.io"
}

variable "github_runner_service_accounts" {
  description = "a list of service accounts to apply IRSA trust policy to. each service account should be in the format `namespace:name`"
  type        = list(string)
  default     = []
}

variable "enable_eks_ssh_access" {
  default = false
}

variable "lead_environments_pipeline_roles" {
  type    = list(string)
  default = []
}

variable "lead_terraform_pipeline_roles" {
  type    = list(string)
  default = []
}

variable "atlantis_namespace" {
  default = "atlantis"
}

variable "github_runners_namespace" {
  default = "github-runners-liatrio"
}

variable "docker_registry_mirror" {
  default = ""
}

variable "s3_logging_id" {
  default = "s3 logging id"
}
