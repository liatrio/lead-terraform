variable "root_zone_name" {
}

variable "cluster" {
  default = "lead"
}

variable "aws_environment" {}

variable "cluster_version" {
  default = "1.15"
}

variable "system_namespace" {
  default = "lead-system"
}

variable "toolchain_namespace" {
  default = "toolchain"
}

variable "region" {
  default = "us-east-1"
}

variable "key_name" {
  default = ""
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
  default = ["m5.xlarge", "c5.xlarge", "m4.xlarge", "c4.xlarge", "t3.xlarge", "r5.xlarge"]
}

variable "essential_taint_key" {
  default = "EssentialOnly"
}

variable "essential_asg_min_size" {
  default = "1"
}

variable "essential_asg_desired_capacity" {
  default = "1"
}

variable "essential_asg_max_size" {
  default = "10"
}

variable "essential_instance_type" {
  default = "t3.large"
}

variable "image_whitelist" {
  default = ".*"
}

variable "opa_failure_policy" {
  default = "Fail"
}

variable "sdm_version" {
  default = "0.4.0-38-gc65319f"
}

variable "product_version" {
  default = "master"
}

variable "dashboard_version" {
  default = "0.2.0-8ed15c3a7e1"
}

variable "cert_issuer_type" {
  default = "acme"
}

variable "enable_istio" {
  default = true
}

variable "enable_artifactory" {
  default = true
}

variable "enable_gitlab" {
  default = true
}

variable "enable_keycloak" {
  default = true
}

variable "enable_google_login" {
  default = false
}

variable "enable_test_user" {
  default = false
}

variable "enable_mailhog" {
  default = false
}

variable "enable_operators" {
  default = true
}

variable "enable_sonarqube" {
  default = true
}

variable "enable_xray" {
  default = true
}

variable "enable_grafeas" {
  default = true
}

variable "enable_harbor" {
  default = true
}

variable "enable_dashboard" {
  default = true
}

variable "enable_autoscaler_scale_down" {
  default = true
}

variable "on_demand_percentage" {
  default = "0"
}

variable "uptime" {
  default = "Mon-Fri 05:00-19:00 America/Los_Angeles"
}
variable "downscaler_exclude_namespaces" {
  type    = list(string)
  default = ["kube-system"]
}
variable "builder_images_version" {
  default = "v1.0.15-7-g2465aa8"
}
variable "jenkins_image_version" {
  default = "v1.0.15-7-g2465aa8"
}
variable "grafeas_version" {
  default = "v0.1.1-4-ge024b96"
}

variable "toolchain_image_repo" {
  default = "artifactory.toolchain.lead.prod.liatr.io/docker-registry/flywheel"
}

variable "prometheus_slack_channel" {
}

locals {
  tags = {
    "Cluster" = var.cluster
  }
}

variable "k8s_storage_class" {
  default = "gp2"
}

variable "dashboard_elasticsearch_replicas" {
  default = 3
}

variable "lead_sdm_operators" {
  type    = list(string)
  default = ["toolchain", "elasticsearch", "slack", "product"]
}

variable "enable_aws_code_services" {
}

variable "product_types" {
  type = list(string)
}

variable "iam_caller_identity_headers" {}

variable "vault_address" {}

variable "lab_partner_version" {
}

variable "enable_lab_partner" {
  default = true
}

variable "team_id" {
}

