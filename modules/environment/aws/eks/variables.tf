variable "region" {
  description = "Default AWS region"
}

variable "cluster" {
  description = "Cluster name"
}

variable "enable_public_endpoint" {
  default = false
}

variable "aws_environment" {}

variable "vpc_id" {
  default = ""
}

variable "system_namespace" {}

variable "toolchain_namespace" {}

variable "key_name" {
  default = ""
}

variable "preemptible_instance_types" {
  type = list
}

variable "preemptible_asg_min_size" {}

variable "preemptible_asg_desired_capacity" {}

variable "preemptible_asg_max_size" {}

variable "essential_instance_type" {}

variable "essential_asg_min_size" {}

variable "essential_asg_desired_capacity" {}

variable "essential_asg_max_size" {}

variable "essential_taint_key" {
  default = "EssentialOnly"
}

variable "on_demand_percentage" {}

variable "workers_additional_policies" {
  default = []
}

# Settings for testing environment
variable "protect_from_scale_in" {
  default = true
}

variable "write_kubeconfig" {
  description = "Flag to create kubeconfig for cluster."
  default     = false
}

variable "kubeconfig_aws_authenticator_additional_args" {
  description = "List of arguments to pass to aws authenticator in kubeconfig"
  default     = []
}

variable "enable_aws_code_services" {}

variable "cluster_version" {
  default = "1.14"
}
