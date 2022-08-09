resource "azurerm_log_analytics_workspace" "aks_log_workspace" {
  name                = "${var.cluster_name}-log-analytics"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_kubernetes_cluster" "main" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.prefix}-k8s"
  # No access avaliable. Should be updated to include VPN access
  api_server_authorized_ip_ranges = ["0.0.0.0/0"]

  network_profile {
    network_policy = "calico"
    network_plugin = "kubenet"
  }

  default_node_pool {
    name       = var.pool_name
    node_count = var.node_count
    vm_size    = var.vm_size
  }

  identity {
    type = "SystemAssigned"
  }

  role_based_access_control {
    enabled = true
  }

  addon_profile {
    aci_connector_linux {
      enabled = false
    }

    azure_policy {
      enabled = false
    }

    http_application_routing {
      enabled = false
    }

    kube_dashboard {
      enabled = true
    }

    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.aks_log_workspace.id
    }
  }
}
