variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group Name"
  type        = string
  default     = "rg-hub-spoke"
}

variable "location" {
  description = "Azure Region"
  type        = string
  default     = "eastus"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "hub_vnet_cidr" {
  description = "Hub VNet CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "spoke1_vnet_cidr" {
  description = "Spoke 1 VNet CIDR block"
  type        = string
  default     = "10.1.0.0/16"
}

variable "spoke2_vnet_cidr" {
  description = "Spoke 2 VNet CIDR block"
  type        = string
  default     = "10.2.0.0/16"
}

variable "hub_firewall_subnet_cidr" {
  description = "Hub Firewall subnet CIDR"
  type        = string
  default     = "10.0.0.0/26"
}

variable "hub_natgw_subnet_cidr" {
  description = "Hub NAT Gateway subnet CIDR"
  type        = string
  default     = "10.0.1.0/26"
}

variable "spoke1_subnet_cidr" {
  description = "Spoke 1 subnet CIDR"
  type        = string
  default     = "10.1.1.0/24"
}

variable "spoke2_subnet_cidr" {
  description = "Spoke 2 subnet CIDR"
  type        = string
  default     = "10.2.1.0/24"
}

variable "vm_size" {
  description = "VM Size"
  type        = string
  default     = "Standard_B1s"
}

variable "vm_image_publisher" {
  description = "VM Image Publisher"
  type        = string
  default     = "Canonical"
}

variable "vm_image_offer" {
  description = "VM Image Offer"
  type        = string
  default     = "0001-com-ubuntu-server-focal"
}

variable "vm_image_sku" {
  description = "VM Image SKU"
  type        = string
  default     = "20_04-lts-gen2"
}

variable "vm_image_version" {
  description = "VM Image Version"
  type        = string
  default     = "latest"
}

variable "admin_username" {
  description = "Admin username for VMs"
  type        = string
  default     = "azureuser"
}
