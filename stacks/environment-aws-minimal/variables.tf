variable "cluster_version" {}

variable "cluster_name" {}

variable "region" {
  default = "us-east-1"
}

variable "key_name" {
  default = ""
}

variable "preemtible_instance_types" {
  type = list
  default = ["m5.xlarge", "c5.xlarge", "m4.xlarge", "c4.xlarge", "t3.xlarge", "r5.xlarge"]
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

variable "vpc_name" {}