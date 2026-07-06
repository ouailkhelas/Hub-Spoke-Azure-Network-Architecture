#!/bin/bash

set -e

echo "Hub & Spoke Architecture Deployment"
echo ""

echo -e "${YELLOW}[1] Checking prerequisites...${NC}"
echo ""

if ! command -v terraform &> /dev/null; then
    echo -e "${RED}Terraform not found. Install it from: https://www.terraform.io/downloads.html${NC}"
    exit 1
fi

if ! command -v az &> /dev/null; then
    echo -e "${RED}Azure CLI not found. Install it from: https://docs.microsoft.com/cli/azure/install-azure-cli${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Terraform installed${NC}"
echo -e "${GREEN}✓ Azure CLI installed${NC}"
echo ""

echo -e "${YELLOW}[2] Login to Azure...${NC}"
az login
echo ""

echo -e "${YELLOW}[3] Checking SSH keys...${NC}"
if [ ! -f ~/.ssh/id_rsa.pub ]; then
    echo -e "${YELLOW}SSH key not found. Generating...${NC}"
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
    echo -e "${GREEN}✓ SSH key generated${NC}"
else
    echo -e "${GREEN}✓ SSH key found${NC}"
fi
echo ""

echo -e "${YELLOW}[4] Initializing Terraform...${NC}"
cd terraform
terraform init
echo -e "${GREEN}✓ Terraform initialized${NC}"
echo ""

echo -e "${YELLOW}[5] Validating Terraform configuration...${NC}"
terraform validate
echo -e "${GREEN}✓ Configuration valid${NC}"
echo ""

echo -e "${YELLOW}[6] Creating deployment plan...${NC}"
terraform plan -out=tfplan
echo ""

echo -e "${YELLOW}Do you want to proceed with deployment? (yes/no)${NC}"
read -r confirmation

if [ "$confirmation" != "yes" ]; then
    echo -e "${RED}Deployment cancelled${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}[7] Deploying infrastructure...${NC}"
echo "This will take approximately 5-10 minutes..."
echo ""
terraform apply tfplan

echo ""
echo -e "${GREEN}======================================"
echo "Deployment Complete!"
echo "======================================${NC}"
echo ""

echo -e "${GREEN}Important Information:${NC}"
terraform output -json | jq .

echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Wait 2-3 minutes for VMs to fully start"
echo "2. Get VM public IPs:"
echo "   terraform output vm_ips"
echo ""
echo "3. SSH to VM 1:"
echo "   $(terraform output -raw ssh_commands | jq -r '.vm1')"
echo ""
echo "4. From VM 1, ping VM 2 (use private IP):"
echo "   ping <VM2_PRIVATE_IP>"
echo ""
echo "5. Configure Firewall Rules in Portal:"
echo "   - Search for 'Firewall' in Portal"
echo "   - Go to 'firewall-hub' > Rules > Add rules"
echo ""
echo "6. Test connectivity:"
echo "   bash ../scripts/test-connectivity.sh"
echo ""
echo -e "${YELLOW}To destroy resources when done:${NC}"
echo "   terraform destroy"
echo ""

cd ..
