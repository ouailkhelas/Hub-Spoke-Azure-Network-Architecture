# Get it with: az account list --query "[].id" -o tsv
subscription_id = "*********************"

# Resource Group Configuration
resource_group_name = "rg-hub-spoke"
location            = "eastus"
environment         = "dev"

# Network Configuration
hub_vnet_cidr              = "10.0.0.0/16"
hub_firewall_subnet_cidr   = "10.0.0.0/26"
hub_natgw_subnet_cidr      = "10.0.1.0/26"

spoke1_vnet_cidr    = "10.1.0.0/16"
spoke1_subnet_cidr  = "10.1.1.0/24"

spoke2_vnet_cidr    = "10.2.0.0/16"
spoke2_subnet_cidr  = "10.2.1.0/24"

# VM Configuration
vm_size = "Standard_B1s"