## Global
variable "resource_group_name" {
  description = "The name of the Azure resource group"
  type        = string
}

variable "location" {
  description = "The Azure Region in which all resources should be provisioned"
  type        = string
}

variable "prefix" {
  description = "A prefix used for resources"
  type        = string
}


## Kubernetes Cluster
variable "cluster_name" {
  description = "The name of the AKS cluster"
  type        = string
}

variable "pool_name" {
  description = "The name of the default_node pool"
  type        = string
}

variable "node_count" {
  description = "The number of nodes"
  type        = number
}

variable "vm_size" {
  description = "The size of the VM"
  type        = string
}