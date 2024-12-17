
variable "resource_group_name" {
  description = "The name of the resource group in which to create the AKS cluster."
  type        = string
  default     = "aks-resource-group"
}

variable "location" {
  description = "The location where the resources will be created."
  type        = string
  default     = "East US"
}

variable "cluster_name" {
  description = "The name of the AKS cluster."
  type        = string
  default     = "aks-cluster"
}

variable "node_count" {
  description = "The number of nodes in the default node pool."
  type        = number
  default     = 1
}

variable "vm_size" {
  description = "The size of the Virtual Machine instances in the default node pool."
  type        = string
  default     = "Standard_DS2_v2"
}