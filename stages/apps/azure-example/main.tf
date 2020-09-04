terraform {
  required_version = ">=0.13"
}

provider "azurerm" {
  version                    = "=2.20.0"
  features {}
}

data "azurerm_kubernetes_cluster" "cluster" {
  name                = var.cluster_name
  resource_group_name = var.resource_group_name
}

provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.fqdn
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.cluster_ca_certificate)
  token                  = data.azurerm_kubernetes_cluster.password
  load_config_file       = false
}

provider "helm" {
  version = "1.1.1"

  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.fqdn
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.cluster_ca_certificate)
    token                  = data.azurerm_kubernetes_cluster.password
    load_config_file       = false
  }
}