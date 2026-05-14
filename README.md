# Hub & Spoke Network Architecture

## 🚀 Overview
This project demonstrates deploying a Hub & Spoke network topology in Azure with Firewall, NAT Gateway, and VNet peering. Uses **Terraform (IaC) + Portal + CLI**.

## ✅ What I Built
- 1 Hub VNet with Azure Firewall and NAT Gateway
- 2 Spoke VNets (connected via peering)
- 2 Linux VMs (one in each spoke)
- Network Security Groups (NSGs)
- VNet Peering (Hub ↔ Spoke)
- Firewall rules for traffic control

## 📍Architecture
```
Spoke VNet 1          Hub VNet          Spoke VNet 2
┌─────────────┐   ┌──────────────┐   ┌─────────────┐
│  VM Linux   │   │  Firewall    │   │  VM Linux   │
│  10.1.1.x   │───│  NAT Gateway │───│  10.2.1.x   │
│   NSG       │   │  10.0.0.0/16 │   │   NSG       │add
└─────────────┘   └──────────────┘   └─────────────┘
   (peering)         (central hub)       (peering)
```

## 📍Technologies Used
- **Infrastructure**: Terraform (IaC)
- **Networking**: Azure VNet, Peering, Firewall, NAT
- **Compute**: 2 Linux VMs (Ubuntu 20.04)
- **Security**: NSGs, Firewall rules
- **Tools**: Azure Portal, Azure CLI, Cloud Shell


## 🎯 How to Deploy

### 📍Phase 1: Infrastructure with Terraform

```bash
cd terraform
terraform init

terraform validate

terraform plan

terraform apply
```
**Terraform creates:**
- Hub VNet (10.0.0.0/16)
- 2 Spoke VNets (10.1.0.0/16, 10.2.0.0/16)
- Subnets in each VNet
- 2 Linux VMs
- Firewall Subnet
- NAT Gateway Subnet
- Network Interfaces
- Public IPs

### 📍Phase 2: Portal configuration
-Configure Firewall Rules
-Create Application Rules
-Create NSG

```

## 🎯 My Contributions to This Project

### Using Terraform (IaC)

✓ Deployed all infrastructure with terraform apply
✓ Created 2 VNets, 3 Subnets per spoke
✓ Deployed Azure Firewall & NAT Gateway
✓ Configured network interfaces
✓ Created Linux VMs with cloud-init


### Using Azure Portal
✓ Created firewall application rules
✓ Created firewall network rules
✓ Configured NSG rules manually
✓ Verified peering connections
✓ Monitored traffic in diagnostic logs


### Using Azure CLI / Cloud Shell

✓ Connected to VMs via SSH
✓ Tested ping between VMs
✓ Checked effective NSG rules
✓ Monitored firewall logs