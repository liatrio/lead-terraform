terraform {
  required_version = ">=0.13"
}

provider "azurerm" {
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
}

provider "helm" {
  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.fqdn
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.cluster_ca_certificate)
    token                  = data.azurerm_kubernetes_cluster.password
  }
}