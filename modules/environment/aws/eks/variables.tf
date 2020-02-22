variable "region" {
  description = "Default AWS region"
}

variable "cluster" {
  description = "Cluster name"
}

variable "system_namespace" {}

variable "toolchain_namespace" {}

variable "key_name" {
  default = ""
}

variable "preemptible_instance_types" {
  type    = list
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

variable "protect_from_scale_in" {
  default = true
}