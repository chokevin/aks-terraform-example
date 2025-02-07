provider "azurerm" {
  features {}
  subscription_id = "137f0351-8235-42a6-ac7a-6b46be2d21c7"
}

module "aks-vpn" {
  source              = "../../modules/aks-vpn"
}