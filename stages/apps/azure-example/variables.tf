variable "resource_group" {
  description = "Azure resource group name"
  default     = "lead"
}

variable "prefix" {
  description = "network name prefix"
  default     = "lead"
}

variable "environment" {
  description = "environment name"
  default     = "sandbox"
}

variable "virtual_network_name" {
  description = "the name of the virtual network"
  default     = "lead-network"
}

variable "subnet_name" {
  description = "The name of the subnet"
  default     = "internal"
}