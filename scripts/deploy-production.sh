#!/bin/bash
# Deploy updated images to production server
set -euo pipefail

SERVER="ubuntu@54.159.26.92"
KEY="$HOME/.ssh/vertify-prod-key.pem"
ECR_REGISTRY="195275664587.dkr.ecr.us-east-1.amazonaws.com"
REGION="us-east-1"
COMPOSE_FILE="~/docker-compose-production.yml"

echo "==> [1/3] Obtendo credenciais ECR para o servidor..."
ECR_PASSWORD=$(aws ecr get-login-password --region "$REGION" --profile default)

echo "==> [2/3] Conectando ao servidor e fazendo login no ECR..."
ssh -i "$KEY" -o StrictHostKeyChecking=no "$SERVER" \
    "echo '$ECR_PASSWORD' | sudo docker login --username AWS --password-stdin $ECR_REGISTRY"

echo "==> [3/3] Atualizando containers em produção..."
ssh -i "$KEY" -o StrictHostKeyChecking=no "$SERVER" bash <<EOF
  set -e
  cd ~
  echo "-- Pull das novas imagens..."
  sudo docker compose -f docker-compose-production.yml pull server cds
  echo "-- Restart dos containers atualizados..."
  sudo docker compose -f docker-compose-production.yml up -d --no-deps server cds
  echo "-- Reiniciando proxy (atualiza resolução de IP dos containers)..."
  sudo docker compose -f docker-compose-production.yml restart proxy
  echo "-- Status final:"
  sudo docker compose -f docker-compose-production.yml ps server cds proxy
EOF

echo ""
echo "✓ Deploy concluído."
