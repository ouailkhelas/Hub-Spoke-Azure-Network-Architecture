# Quick Reference Guide
### Quick Deploy (5 minutes)

```bash
# 1. Get subscription ID
az account list --query "[].id" -o tsv

# 2. Edit terraform.tfvars
# Set: subscription_id = "your-id-here"
nano terraform/terraform.tfvars

# 3. Deploy
cd terraform
terraform init
terraform apply

# Type: yes when asked

# 4. Get outputs
terraform output
```

### Connect to VMs

```bash
# SSH to VM 1
ssh azureuser@<VM1_PUBLIC_IP>

# From VM 1, ping VM 2
ping <VM2_PRIVATE_IP>

# SSH from VM 1 to VM 2
ssh <VM2_PRIVATE_IP>
```

### Check Status

```bash
# Peering status
az network vnet peering list -g rg-hub-spoke --vnet-name vnet-hub -o table

# Firewall status
az network firewall show -g rg-hub-spoke -n firewall-hub

# NAT Gateway status
az network nat gateway show -g rg-hub-spoke -n natgw-hub
```

### Traffic Flow
```
VM 1 → (peering) → Hub Firewall → (peering) → VM 2
  ↓
  NAT Gateway (for outbound)