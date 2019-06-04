variable "root_zone_name" {} 
variable "cluster" {}
variable "namespace" {}
variable "elb_security_group_id" {}

locals {
  tags = {
    "Cluster"  = "${var.cluster}"
  }
}
