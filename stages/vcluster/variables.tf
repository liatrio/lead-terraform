variable "host_cluster_name" {
  description = "The name of the EKS cluster to deploy this vcluster to"
}

variable "host_cluster_namespace" {
  description = "The name of the namespace to create to host this vcluster"
}

// not the easiest thing to find, especially on a managed k8s provider such as EKS.
// this one-liner should give you the correct value:
// echo '{"apiVersion":"v1","kind":"Service","metadata":{"name":"test"},"spec":{"clusterIP":"1.1.1.1","ports":[{"port":443}]}}' | kubectl apply -f - 2>&1 | sed 's/.*valid IPs is //'
variable "host_cluster_service_cidr" {}

variable "vcluster_apiserver_host" {
  description = "The host to use for the vcluster apiserver"
}

variable "aws_region" {
  default = "us-east-1"
}

variable "vcluster_apiserver_ingress_class" {
  description = "The ingress class used to expose the vcluster apiserver"
}
