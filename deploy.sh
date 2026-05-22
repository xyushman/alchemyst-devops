#!/bin/bash
set -e

echo "==> Getting your current IP..."
MY_IP=$(curl -s https://checkip.amazonaws.com)/32

echo "==> Applying Terraform (infrastructure + inventory)..."
cd ~/Desktop/alchemyst-devops/terraform
terraform apply -auto-approve -var "your_ip=$MY_IP"

echo "==> Deploying gateway (engine + caller-worker)..."
cd ~/Desktop/alchemyst-devops/ansible
ansible-playbook -i inventory.ini playbooks/setup-gateway.yml

echo "==> Deploying inference worker..."
ansible-playbook -i inventory.ini playbooks/setup-inference.yml

echo "==> Waiting 2 minutes for model to download and load..."
sleep 120

GATEWAY_IP=$(terraform -chdir=../terraform output -raw gateway_public_ip)

echo "==> Testing API..."
curl -X POST http://$GATEWAY_IP:3111/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{"messages":[{"role":"user","content":"What is the capital of France?"}]}' \
  --max-time 300

echo ""
echo "Done! If you see JSON above, the deployment is fully working."
