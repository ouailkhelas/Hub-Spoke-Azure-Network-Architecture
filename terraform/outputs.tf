output "resource_group_name" {
  description = "Resource Group Name"
  value       = azurerm_resource_group.hub_spoke.name
}

output "hub_vnet_id" {
  description = "Hub VNet ID"
  value       = azurerm_virtual_network.hub.id
}

output "spoke1_vnet_id" {
  description = "Spoke 1 VNet ID"
  value       = azurerm_virtual_network.spoke1.id
}

output "spoke2_vnet_id" {
  description = "Spoke 2 VNet ID"
  value       = azurerm_virtual_network.spoke2.id
}

output "firewall_public_ip" {
  description = "Firewall Public IP Address"
  value       = azurerm_public_ip.firewall.ip_address
}

output "nat_gateway_public_ip" {
  description = "NAT Gateway Public IP Address"
  value       = azurerm_public_ip.nat.ip_address
}

output "vm1_public_ip" {
  description = "VM 1 (Spoke 1) Public IP"
  value       = azurerm_public_ip.vm1.ip_address
}

output "vm1_private_ip" {
  description = "VM 1 (Spoke 1) Private IP"
  value       = azurerm_network_interface.vm1.private_ip_address
}

output "vm2_public_ip" {
  description = "VM 2 (Spoke 2) Public IP"
  value       = azurerm_public_ip.vm2.ip_address
}

output "vm2_private_ip" {
  description = "VM 2 (Spoke 2) Private IP"
  value       = azurerm_network_interface.vm2.private_ip_address
}

output "vm_ips" {
  description = "All VM IP addresses"
  value = {
    vm1_public  = azurerm_public_ip.vm1.ip_address
    vm1_private = azurerm_network_interface.vm1.private_ip_address
    vm2_public  = azurerm_public_ip.vm2.ip_address
    vm2_private = azurerm_network_interface.vm2.private_ip_address
  }
}

output "ssh_commands" {
  description = "SSH commands to connect to VMs"
  value = {
    vm1 = "ssh azureuser@${azurerm_public_ip.vm1.ip_address}"
    vm2 = "ssh azureuser@${azurerm_public_ip.vm2.ip_address}"
  }
}

output "peering_status" {
  description = "VNet Peering Information"
  value = {
    hub_to_spoke1 = azurerm_virtual_network_peering.hub_to_spoke1.id
    spoke1_to_hub = azurerm_virtual_network_peering.spoke1_to_hub.id
    hub_to_spoke2 = azurerm_virtual_network_peering.hub_to_spoke2.id
    spoke2_to_hub = azurerm_virtual_network_peering.spoke2_to_hub.id
  }
}
