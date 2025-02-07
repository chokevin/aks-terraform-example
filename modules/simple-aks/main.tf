terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "137f0351-8235-42a6-ac7a-6b46be2d21c7"
}

resource "azurerm_resource_group" "aks_rg" {
  name     = "aks-resource-group"
  location = "East US"
}

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = "kevins-test"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = "akscluster"

  default_node_pool {
    name       = "agentpool"
    node_count = 1
    vm_size    = "standard_d2a_v4"
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "userpool" {
  name                  = "userpool2"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks_cluster.id
  vm_size               = "standard_d2a_v4"
  node_count            = 1
  mode                  = "User"
  max_pods              = 110
  os_disk_size_gb       = 30
  os_type               = "Linux"
  node_labels = {
    "agentpool" = "userpool"
  }
}
