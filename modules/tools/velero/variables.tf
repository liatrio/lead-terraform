variable "enable_velero" {}
variable "bucket_name" {}
variable "region" {}
variable "cluster_name" {}
variable "namespace" {
  default = "velero"
}
variable "velero_aws_access_key_id" {}
variable "velero_aws_secret_access_key" {}