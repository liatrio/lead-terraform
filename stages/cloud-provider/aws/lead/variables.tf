variable "cluster_version" {
  description = "Kubernetes version running on EKS"
}

variable "cluster_addons" {
  description = "EKS addons to install to the cluster"
  type        = map(string)
  default     = {}
}

variable "cluster_name" {
  description = "Name of the cluster as seen in EKS"
}

variable "region" {
  default     = "us-east-1"
  description = "AWS Region to use for resource creation and reference"
}

variable "key_name" {
  default     = ""
  description = "Key name for workers, setting to empty string disables remote access"
}

variable "asg_min_size" {
  default = "1"
}

variable "asg_desired_capacity" {
  default = "1"
}

variable "asg_max_size" {
  default = "5"
}

variable "instance_types" {
  type    = list(string)
  default = ["m5.xlarge", "m4.xlarge", "t3.xlarge", "r5.xlarge"]
}

variable "essential_instance_type" {
  default     = "t3.large"
  description = "Allowed type of essential EC2 workers"
}

variable "essential_asg_min_size" {
  default     = "1"
  description = "Minimum autoscaling group size provsioned with AWS EC2 instances"
}

variable "essential_asg_desired_capacity" {
  default     = "1"
  description = "Desired autoscaling group size provsioned with AWS EC2 instances"
}

variable "essential_asg_max_size" {
  default     = "5"
  description = "Maximum autoscaling group size provsioned with AWS EC2 instances"
}

variable "essential_taint_key" {
  default     = "EssentialOnly"
  description = "String used to taint EKS nodes to prevent scheduling of non-essential pods"
}

variable "on_demand_percentage" {
  default     = "0"
  description = "Percentage on nodes will be on-demand instances; If not set, all nodes will be spot instances"
}

variable "enable_aws_code_services" {
  default     = false
  description = "Feature flag for adding a codebuild IAM role to the aws-auth configmap"
}

variable "vpc_name" {
  description = "Name of the AWS VPC to be used by the EKS cluster"
}

variable "additional_mapped_roles" {
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default     = []
  description = "Additional IAM roles to be added to added to the aws-auth configmap"
}

variable "system_namespace" {
  default = "lead-system"
}

variable "toolchain_namespace" {
  default = "toolchain"
}

variable "root_zone_name" {
}

locals {
  tags = {
    "Cluster" = var.cluster_name
  }
}

variable "docker_registry_mirror" {
  default = ""
}

variable "github_runner_service_accounts" {
  description = "a list of service accounts to apply IRSA trust policy to. each service account should be in the format `namespace:name`"
  type        = list(string)
  default     = []
}

variable "enable_velero" {
  default = false
}

variable "velero_namespace" {
  default = "velero"
}

variable "enable_eks_ssh_access" {
  default = false
}

variable "enable_vcluster" {
  default = false
}

variable "s3_logging_id" {
  default = "s3 logging id"
}
