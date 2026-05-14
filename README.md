# Hub & Spoke Network Architecture - Entry Level

## Overview
This project demonstrates deploying a Hub & Spoke network topology in Azure with Firewall, NAT Gateway, and VNet peering. Uses **Terraform (IaC) + Portal + CLI**.

## What I Built
- 1 Hub VNet with Azure Firewall and NAT Gateway
- 2 Spoke VNets (connected via peering)
- 2 Linux VMs (one in each spoke)
- Network Security Groups (NSGs)
- VNet Peering (Hub ↔ Spoke)
- Firewall rules for traffic control

## Architecture
```
Spoke VNet 1          Hub VNet          Spoke VNet 2
┌─────────────┐   ┌──────────────┐   ┌─────────────┐
│  VM Linux   │   │  Firewall    │   │  VM Linux   │
│  10.1.1.x   │───│  NAT Gateway │───│  10.2.1.x   │
│   NSG       │   │  10.0.0.0/16 │   │   NSG       │
└─────────────┘   └──────────────┘   └─────────────┘
   (peering)         (central hub)       (peering)
```

## Technologies Used
- **Infrastructure**: Terraform (IaC)
- **Networking**: Azure VNet, Peering, Firewall, NAT
- **Compute**: 2 Linux VMs (Ubuntu 20.04)
- **Security**: NSGs, Firewall rules
- **Tools**: Azure Portal, Azure CLI, Cloud Shell

## Project Files
```
terraform/
├── main.tf              # Main configuration
├── variables.tf         # Variable definitions
├── outputs.tf           # Output values
├── terraform.tfvars     # Values (CHANGE THESE)
└── provider.tf          # Azure provider

scripts/
├── deploy-terraform.sh  # Deploy IaC
├── setup-peering.sh     # Setup VNet peering
├── configure-firewall.sh # Configure firewall rules
└── test-connectivity.sh # Test VM connectivity

docs/
└── deployment-steps.md  # Step-by-step guide
```

## How to Deploy

### Phase 1: Infrastructure with Terraform

```bash
# Step 1: Initialize Terraform
cd terraform
terraform init

# Step 2: Validate configuration
terraform validate

# Step 3: Preview changes
terraform plan

# Step 4: Deploy infrastructure
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

### Phase 2: Configure Firewall Rules (Portal)

```
1. Go to Azure Portal
2. Search: "Firewall"
3. Open "firewall-hub"
4. Settings > Rules (Classic)

Create Application Rules:
┌────────────────────────────┐
│ Allow Linux VM SSH Updates │
├────────────────────────────┤
│ Source:    *               │
│ Protocol:  TCP             │
│ Port:      22              │
│ Destination: 10.1.0.0/16   │
└────────────────────────────┘

Create Network Rules:
┌────────────────────────────┐
│ Allow Spoke to Spoke       │
├────────────────────────────┤
│ Source:    10.1.0.0/16     │
│ Protocol:  TCP,UDP         │
│ Port:      *               │
│ Dest:      10.2.0.0/16     │
└────────────────────────────┘
```

### Phase 3: Test Connectivity (Cloud Shell)

```bash
# Run test script
bash scripts/test-connectivity.sh

# This will:
✓ Verify peering status
✓ Test SSH connectivity between VMs
✓ Check NSG rules
✓ Verify firewall rules
✓ Test NAT Gateway function
```

## My Contributions to This Project

### Using Terraform (IaC)
```
✓ Deployed all infrastructure with terraform apply
✓ Created 2 VNets, 3 Subnets per spoke
✓ Deployed Azure Firewall & NAT Gateway
✓ Configured network interfaces
✓ Created Linux VMs with cloud-init
```

### Using Azure Portal
```
✓ Created firewall application rules
✓ Created firewall network rules
✓ Configured NSG rules manually
✓ Verified peering connections
✓ Monitored traffic in diagnostic logs
```

### Using Azure CLI / Cloud Shell
```
✓ Connected to VMs via SSH
✓ Tested ping between VMs
✓ Checked effective NSG rules
✓ Monitored firewall logs
✓ Validated NAT Gateway IP addresses
```

## Quick Start (5 minutes)

```bash
# 1. Clone this repo
git clone <repo-url>
cd hub-spoke-architecture

# 2. Update variables
# Edit terraform/terraform.tfvars:
#   - subscription_id
#   - resource_group_name
#   - location

# 3. Deploy
cd terraform
terraform init
terraform apply

# 4. Get VM IPs
terraform output vm_ips

# 5. SSH to VM 1
ssh azureuser@<VM1_PUBLIC_IP>

# 6. Ping VM 2 (from VM 1)
ping <VM2_PRIVATE_IP>
```

## Key Concepts Learned

### VNet Peering
- Hub-Spoke topology benefits
- Bidirectional communication
- No cost between peered VNets
- Regional peering

### Azure Firewall
- Centralized firewall in Hub
- Application rules (FQDNs)
- Network rules (IPs/Ports)
- NAT rules (Port forwarding)

### NAT Gateway
- Outbound connectivity
- Static public IP
- Multiple VMs → Single IP
- Cost per hour

### Network Security Groups
- Subnet level filtering
- Inbound/Outbound rules
- Effective rules view
- Service tags

### VMs & Linux
- Cloud-init scripts
- SSH key authentication
- System updates
- Basic diagnostics

## Entry Level Features
✓ Simple Terraform - only essential resources
✓ Minimal variables - easy to customize
✓ Portal walkthrough - understand firewall config
✓ Real resources - working architecture
✓ Documented steps - anyone can follow
✓ Test scripts - validate everything works

## Useful Commands

```bash
# Show Terraform state
terraform show

# Destroy everything (when done testing)
terraform destroy

# Get specific output
terraform output vm_ips

# SSH to VM
ssh azureuser@<PUBLIC_IP>

# Check routing inside Hub
az network route-table list -g <rg>

# View firewall logs
az monitor log-analytics query \
  --workspace <workspace-id> \
  --analytics-query "AzureDiagnostics"
```

## Architecture Validation

```
✓ Hub VNet deployed (10.0.0.0/16)
✓ Spoke 1 peered to Hub
✓ Spoke 2 peered to Hub
✓ Firewall subnet ready
✓ NAT Gateway active
✓ NSGs protecting subnets
✓ Both VMs running
✓ SSH connectivity working
✓ Cross-spoke communication through firewall
✓ Outbound NAT translation active
```

## Estimated Cost (1 month)
- Hub VNet: ~$0 (free)
- Spoke VNets: ~$0 (free)
- 2 VMs (B1s): ~$30
- Firewall: ~$1.25/day (~$38)
- NAT Gateway: ~$0.45/day (~$14)
- **Total: ~$82/month**

## Next Steps
1. Add more spokes for scale
2. Implement Azure Virtual WAN
3. Add Application Gateway
4. Setup DDoS protection
5. Enable diagnostics logging
6. Implement advanced firewall rules

## Resources
- [Hub-Spoke topology](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke)
- [Azure Firewall docs](https://docs.microsoft.com/en-us/azure/firewall/)
- [VNet Peering](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-peering-overview)
- [NAT Gateway](https://docs.microsoft.com/en-us/azure/virtual-network/nat-gateway/nat-overview)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

---
**Certified**: AZ-900, AZ-104
**Entry Level**: Suitable for beginners & learning
**Time to Deploy**: ~15 minutes
**Time to Understand**: ~2-3 hours
