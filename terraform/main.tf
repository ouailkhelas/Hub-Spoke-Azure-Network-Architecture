# RESOURCE GROUP
resource "azurerm_resource_group" "hub_spoke" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    environment = var.environment
    project     = "hub-spoke"
  }
}

# HUB VNET
resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hub"
  address_space       = [var.hub_vnet_cidr]
  location            = azurerm_resource_group.hub_spoke.location
  resource_group_name = azurerm_resource_group.hub_spoke.name

  tags = {
    role = "hub"
  }
}

# Hub Firewall Subnet
resource "azurerm_subnet" "hub_firewall" {
  name                 = "AzureFirewallSubnet" # Must be exactly this name
  resource_group_name  = azurerm_resource_group.hub_spoke.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.hub_firewall_subnet_cidr]
}

# Hub NAT Gateway Subnet
resource "azurerm_subnet" "hub_natgw" {
  name                 = "subnet-natgw"
  resource_group_name  = azurerm_resource_group.hub_spoke.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.hub_natgw_subnet_cidr]
}

# SPOKE 1 VNET
resource "azurerm_virtual_network" "spoke1" {
  name                = "vnet-spoke1"
  address_space       = [var.spoke1_vnet_cidr]
  location            = azurerm_resource_group.hub_spoke.location
  resource_group_name = azurerm_resource_group.hub_spoke.name

  tags = {
    role = "spoke"
  }
}

resource "azurerm_subnet" "spoke1" {
  name                 = "subnet-spoke1"
  resource_group_name  = azurerm_resource_group.hub_spoke.name
  virtual_network_name = azurerm_virtual_network.spoke1.name
  address_prefixes     = [var.spoke1_subnet_cidr]
}

# SPOKE 2 VNET
resource "azurerm_virtual_network" "spoke2" {
  name                = "vnet-spoke2"
  address_space       = [var.spoke2_vnet_cidr]
  location            = azurerm_resource_group.hub_spoke.location
  resource_group_name = azurerm_resource_group.hub_spoke.name

  tags = {
    role = "spoke"
  }
}

resource "azurerm_subnet" "spoke2" {
  name                 = "subnet-spoke2"
  resource_group_name  = azurerm_resource_group.hub_spoke.name
  virtual_network_name = azurerm_virtual_network.spoke2.name
  address_prefixes     = [var.spoke2_subnet_cidr]
}

# VNET PEERING - Hub to Spoke 1
resource "azurerm_virtual_network_peering" "hub_to_spoke1" {
  name                      = "peer-hub-spoke1"
  resource_group_name       = azurerm_resource_group.hub_spoke.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.spoke1.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "spoke1_to_hub" {
  name                      = "peer-spoke1-hub"
  resource_group_name       = azurerm_resource_group.hub_spoke.name
  virtual_network_name      = azurerm_virtual_network.spoke1.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

# VNET PEERING - Hub to Spoke 2
resource "azurerm_virtual_network_peering" "hub_to_spoke2" {
  name                      = "peer-hub-spoke2"
  resource_group_name       = azurerm_resource_group.hub_spoke.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.spoke2.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "spoke2_to_hub" {
  name                      = "peer-spoke2-hub"
  resource_group_name       = azurerm_resource_group.hub_spoke.name
  virtual_network_name      = azurerm_virtual_network.spoke2.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

# PUBLIC IPS
# Firewall Public IP
resource "azurerm_public_ip" "firewall" {
  name                = "pip-firewall"
  location            = azurerm_resource_group.hub_spoke.location
  resource_group_name = azurerm_resource_group.hub_spoke.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# NAT Gateway Public IP
resource "azurerm_public_ip" "nat" {
  name                = "pip-nat"
  location            = azurerm_resource_group.hub_spoke.location
  resource_group_name = azurerm_resource_group.hub_spoke.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# VM 1 Public IP
resource "azurerm_public_ip" "vm1" {
  name                = "pip-vm1"
  location            = azurerm_resource_group.hub_spoke.location
  resource_group_name = azurerm_resource_group.hub_spoke.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# VM 2 Public IP
resource "azurerm_public_ip" "vm2" {
  name                = "pip-vm2"
  location            = azurerm_resource_group.hub_spoke.location
  resource_group_name = azurerm_resource_group.hub_spoke.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# AZURE FIREWALL
resource "azurerm_firewall" "hub" {
  name                = "firewall-hub"
  location            = azurerm_resource_group.hub_spoke.location
  resource_group_name = azurerm_resource_group.hub_spoke.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.hub_firewall.id
    public_ip_address_id = azurerm_public_ip.firewall.id
  }

  tags = {
    role = "central-firewall"
  }
}

# NAT GATEWAY
resource "azurerm_nat_gateway" "hub" {
  name                = "natgw-hub"
  location            = azurerm_resource_group.hub_spoke.location
  resource_group_name = azurerm_resource_group.hub_spoke.name
  sku_name            = "Standard"

  tags = {
    role = "outbound-nat"
  }
}

resource "azurerm_nat_gateway_public_ip_association" "hub" {
  nat_gateway_id       = azurerm_nat_gateway.hub.id
  public_ip_address_id = azurerm_public_ip.nat.id
}

resource "azurerm_subnet_nat_gateway_association" "spoke1" {
  subnet_id      = azurerm_subnet.spoke1.id
  nat_gateway_id = azurerm_nat_gateway.hub.id
}

resource "azurerm_subnet_nat_gateway_association" "spoke2" {
  subnet_id      = azurerm_subnet.spoke2.id
  nat_gateway_id = azurerm_nat_gateway.hub.id
}

# NETWORK SECURITY GROUPS - SPOKE 1
resource "azurerm_network_security_group" "spoke1" {
  name                = "nsg-spoke1"
  location            = azurerm_resource_group.hub_spoke.location
  resource_group_name = azurerm_resource_group.hub_spoke.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowSpokeToSpoke"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.2.0.0/16"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "DenyAll"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    role = "spoke"
  }
}

# NETWORK SECURITY GROUPS - SPOKE 2
resource "azurerm_network_security_group" "spoke2" {
  name                = "nsg-spoke2"
  location            = azurerm_resource_group.hub_spoke.location
  resource_group_name = azurerm_resource_group.hub_spoke.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowSpokeToSpoke"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.1.0.0/16"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "DenyAll"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    role = "spoke"
  }
}

# NETWORK INTERFACES - VM 1 (SPOKE 1)
resource "azurerm_network_interface" "vm1" {
  name                = "nic-vm1"
  location            = azurerm_resource_group.hub_spoke.location
  resource_group_name = azurerm_resource_group.hub_spoke.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.spoke1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm1.id
  }
}

resource "azurerm_network_interface_security_group_association" "vm1" {
  network_interface_id      = azurerm_network_interface.vm1.id
  network_security_group_id = azurerm_network_security_group.spoke1.id
}

# NETWORK INTERFACES - VM 2 (SPOKE 2)
resource "azurerm_network_interface" "vm2" {
  name                = "nic-vm2"
  location            = azurerm_resource_group.hub_spoke.location
  resource_group_name = azurerm_resource_group.hub_spoke.name

  ip_configuration {
    name                          = "testconfiguration2"
    subnet_id                     = azurerm_subnet.spoke2.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm2.id
  }
}

resource "azurerm_network_interface_security_group_association" "vm2" {
  network_interface_id      = azurerm_network_interface.vm2.id
  network_security_group_id = azurerm_network_security_group.spoke2.id
}

# LINUX VIRTUAL MACHINES
# VM 1 in Spoke 1
resource "azurerm_linux_virtual_machine" "vm1" {
  name                = "vm-spoke1-01"
  location            = azurerm_resource_group.hub_spoke.location
  resource_group_name = azurerm_resource_group.hub_spoke.name
  size                = var.vm_size

  disable_password_authentication = true

  admin_username = var.admin_username

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = var.vm_image_publisher
    offer     = var.vm_image_offer
    sku       = var.vm_image_sku
    version   = var.vm_image_version
  }

  network_interface_ids = [
    azurerm_network_interface.vm1.id,
  ]

  tags = {
    role = "spoke1-vm"
  }

  depends_on = [
    azurerm_network_interface_security_group_association.vm1
  ]
}

# VM 2 in Spoke 2
resource "azurerm_linux_virtual_machine" "vm2" {
  name                = "vm-spoke2-01"
  location            = azurerm_resource_group.hub_spoke.location
  resource_group_name = azurerm_resource_group.hub_spoke.name
  size                = var.vm_size

  disable_password_authentication = true

  admin_username = var.admin_username

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = var.vm_image_publisher
    offer     = var.vm_image_offer
    sku       = var.vm_image_sku
    version   = var.vm_image_version
  }

  network_interface_ids = [
    azurerm_network_interface.vm2.id,
  ]

  tags = {
    role = "spoke2-vm"
  }

  depends_on = [
    azurerm_network_interface_security_group_association.vm2
  ]
}
