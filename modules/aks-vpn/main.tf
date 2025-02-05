resource "azurerm_resource_group" "aks" {
    name     = "kevinvpntestgroup"
    location = "East US"
}

resource "azurerm_virtual_network" "aks_vnet" {
    name                = "aks-vnet"
    address_space       = ["10.0.0.0/16"]
    location            = azurerm_resource_group.aks.location
    resource_group_name = azurerm_resource_group.aks.name
}

resource "azurerm_subnet" "aks_subnet" {
    name                 = "aks-subnet"
    resource_group_name  = azurerm_resource_group.aks.name
    virtual_network_name = azurerm_virtual_network.aks_vnet.name
    address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "firewall_subnet" {
    name                 = "AzureFirewallSubnet"
    resource_group_name  = azurerm_resource_group.aks.name
    virtual_network_name = azurerm_virtual_network.aks_vnet.name
    address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_kubernetes_cluster" "aks" {
    name                = "aks-cluster"
    location            = azurerm_resource_group.aks.location
    resource_group_name = azurerm_resource_group.aks.name
    dns_prefix          = "aksdns"

    default_node_pool {
        name       = "default"
        node_count = 1
        vm_size    = "standard_d32a_v4"
        vnet_subnet_id = azurerm_subnet.aks_subnet.id
    }

    identity {
        type = "SystemAssigned"
    }

    network_profile {
        network_plugin    = "azure"
        network_policy    = "azure"
        service_cidr      = "10.0.3.0/24"
        dns_service_ip    = "10.0.3.10"
    }
}

resource "azurerm_virtual_network" "remote_vnet" {
    name                = "remote-vnet"
    address_space       = ["10.1.0.0/16"]
    location            = azurerm_resource_group.aks.location
    resource_group_name = azurerm_resource_group.aks.name
}

resource "azurerm_virtual_network_peering" "vnet_peering" {
    name                      = "vnet-peering"
    resource_group_name       = azurerm_resource_group.aks.name
    virtual_network_name      = azurerm_virtual_network.aks_vnet.name
    remote_virtual_network_id = azurerm_virtual_network.remote_vnet.id
    allow_virtual_network_access = true
    allow_forwarded_traffic      = true
    allow_gateway_transit        = false
    use_remote_gateways          = false
}

resource "azurerm_public_ip" "public_ip" {
  name                = "test-public-ip"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "example" {
    name                = "azurefirewall"
    location            = azurerm_resource_group.aks.location
    resource_group_name = azurerm_resource_group.aks.name
    sku_name = "AZFW_VNet"
    sku_tier = "Standard"
    ip_configuration {
        name                 = azurerm_subnet.firewall_subnet.name
        subnet_id            = azurerm_subnet.firewall_subnet.id
        public_ip_address_id = azurerm_public_ip.public_ip.id
    }
}

resource "azurerm_firewall_policy" "example" {
    name                = "example-firewall-policy"
    resource_group_name = azurerm_resource_group.aks.name
    location            = azurerm_resource_group.aks.location
}