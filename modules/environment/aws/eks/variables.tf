variable "region" {
  description = "Default AWS region"
}

variable "cluster" {
  description = "Cluster name"
}

variable "enable_public_endpoint" {
  default = false
}

variable "vpc_name" {}

variable "key_name" {
  default = ""
}

variable "spot_instance_types" {
  type = list(any)
}

variable "spot_asg_min_size" {}

variable "spot_asg_desired_capacity" {}

variable "spot_asg_max_size" {}

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

variable "enable_aws_code_services" {
  default = false
}

variable "additional_mapped_roles" {
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}

variable "cluster_version" {
}

variable "cluster_addons" {
  type    = map(string)
  default = {}
}

variable "codebuild_role" {
  default = ""
}

variable "root_volume_size" {
  default = 50
}

variable "docker_registry_mirror" {
  default = ""
}

variable "internal_vpn_subnet" {
  default = "10.1.32.0/20"
}

variable "shared_svc_subnet" {
  default = "10.2.0.0/16"
}

variable "enable_ssh_access" {
  default = false
}

variable "s3_logging_id" {}
