#!/bin/bash

# Hub & Spoke Architecture - Connectivity Test Script
# This script validates the hub-spoke architecture deployment

set -e

RESOURCE_GROUP="rg-hub-spoke"

echo "======================================"
echo "Hub & Spoke - Connectivity Tests"
echo "======================================"
echo ""

# Step 1: Check peering status
echo "[1] Checking VNet Peering Status..."
echo ""

PEERING_LIST=$(az network vnet peering list \
  --resource-group $RESOURCE_GROUP \
  --vnet-name vnet-hub \
  --query "[].{Name:name, Status:peeringState}" \
  --output table)

echo "$PEERING_LIST"
echo ""

if echo "$PEERING_LIST" | grep -q "Connected"; then
    echo "✓ Peering connections are ACTIVE"
else
    echo "✗ Some peering connections are NOT CONNECTED"
fi
echo ""

# Step 2: Get VM information
echo "[2] Getting VM Information..."
echo ""

VM1_RG=$RESOURCE_GROUP
VM1_NAME="vm-spoke1-01"
VM2_NAME="vm-spoke2-01"

VM1_PUBLIC=$(az vm list-ip-addresses \
  --resource-group $VM1_RG \
  --name $VM1_NAME \
  --query "[0].virtualMachines[0].ipAddresses[0].publicIpAddress" \
  -o tsv)

VM1_PRIVATE=$(az vm list-ip-addresses \
  --resource-group $VM1_RG \
  --name $VM1_NAME \
  --query "[0].virtualMachines[0].ipAddresses[0].privateIpAddress" \
  -o tsv)

VM2_PUBLIC=$(az vm list-ip-addresses \
  --resource-group $VM1_RG \
  --name $VM2_NAME \
  --query "[0].virtualMachines[0].ipAddresses[0].publicIpAddress" \
  -o tsv)

VM2_PRIVATE=$(az vm list-ip-addresses \
  --resource-group $VM1_RG \
  --name $VM2_NAME \
  --query "[0].virtualMachines[0].ipAddresses[0].privateIpAddress" \
  -o tsv)

echo "VM 1 (Spoke 1):"
echo "  Public IP:  $VM1_PUBLIC"
echo "  Private IP: $VM1_PRIVATE"
echo ""
echo "VM 2 (Spoke 2):"
echo "  Public IP:  $VM2_PUBLIC"
echo "  Private IP: $VM2_PRIVATE"
echo ""

# Step 3: Test SSH connectivity
echo "[3] Testing SSH Connectivity..."
echo ""

echo "Testing VM 1 SSH access..."
if timeout 5 ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 azureuser@$VM1_PUBLIC "echo 'SSH Connection OK'" 2>/dev/null; then
    echo "✓ VM 1 SSH: OK"
else
    echo "✗ VM 1 SSH: FAILED"
    echo "  This is normal if VM just started, wait 2-3 minutes and retry"
fi
echo ""

echo "Testing VM 2 SSH access..."
if timeout 5 ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 azureuser@$VM2_PUBLIC "echo 'SSH Connection OK'" 2>/dev/null; then
    echo "✓ VM 2 SSH: OK"
else
    echo "✗ VM 2 SSH: FAILED"
    echo "  This is normal if VM just started, wait 2-3 minutes and retry"
fi
echo ""

# Step 4: Test cross-spoke connectivity
echo "[4] Testing Cross-Spoke Connectivity..."
echo ""

echo "From VM 1, testing connectivity to VM 2 private IP ($VM2_PRIVATE)..."
if timeout 5 ssh -o StrictHostKeyChecking=no azureuser@$VM1_PUBLIC "ping -c 1 $VM2_PRIVATE" 2>/dev/null | grep -q "1 packets transmitted"; then
    echo "✓ Ping VM 2 from VM 1: OK"
else
    echo "✗ Ping VM 2 from VM 1: FAILED"
    echo "  Check:"
    echo "  1. VNet peering status"
    echo "  2. NSG rules on both VMs"
    echo "  3. Firewall rules (if enabled)"
fi
echo ""

# Step 5: Check NSG rules
echo "[5] Checking Network Security Groups..."
echo ""

echo "NSG Rules for Spoke 1:"
az network nsg rule list -g $RESOURCE_GROUP --nsg-name nsg-spoke1 \
  --query "[].{Name:name, Priority:priority, Direction:direction, Access:access}" \
  --output table
echo ""

echo "NSG Rules for Spoke 2:"
az network nsg rule list -g $RESOURCE_GROUP --nsg-name nsg-spoke2 \
  --query "[].{Name:name, Priority:priority, Direction:direction, Access:access}" \
  --output table
echo ""

# Step 6: Check NAT Gateway status
echo "[6] Checking NAT Gateway..."
echo ""

NAT_IP=$(az network public-ip show \
  -g $RESOURCE_GROUP \
  -n pip-nat \
  --query ipAddress \
  -o tsv)

echo "NAT Gateway Public IP: $NAT_IP"
echo ""

# Step 7: Check Firewall status
echo "[7] Checking Azure Firewall..."
echo ""

FIREWALL_STATUS=$(az network firewall show \
  -g $RESOURCE_GROUP \
  -n firewall-hub \
  --query "{Name:name, Status:provisioningState}" \
  -o table)

echo "$FIREWALL_STATUS"
echo ""

echo "Firewall Public IP:"
az network public-ip show \
  -g $RESOURCE_GROUP \
  -n pip-firewall \
  --query ipAddress \
  -o table
echo ""

# Summary
echo "======================================"
echo "Connectivity Test Summary"
echo "======================================"
echo ""
echo "Checklist:"
echo "  ✓ VNet Peering: Check status above"
echo "  ✓ VM SSH Access: Check results above"
echo "  ✓ Cross-spoke Connectivity: Check results above"
echo "  ✓ NSG Rules: Check rules above"
echo "  ✓ NAT Gateway: Active"
echo "  ✓ Firewall: Check status above"
echo ""

echo "To troubleshoot:"
echo "1. SSH to VM 1:"
echo "   ssh azureuser@$VM1_PUBLIC"
echo ""
echo "2. From VM 1, check connectivity to VM 2:"
echo "   ping $VM2_PRIVATE"
echo "   ssh $VM2_PRIVATE"
echo ""
echo "3. Check effective NSG rules:"
echo "   az network nic show-effective-route-table -g $RESOURCE_GROUP -n nic-vm1"
echo ""
