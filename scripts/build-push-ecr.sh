#!/bin/bash
# Build and push vertify-server and design-studio images to ECR
set -euo pipefail

ECR_REGISTRY="195275664587.dkr.ecr.us-east-1.amazonaws.com"
REGION="us-east-1"
TAG="production-1.0.0"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Use sudo if current user can't access Docker socket directly
DOCKER="docker"
if ! docker info &>/dev/null 2>&1; then
    DOCKER="sudo docker"
fi

echo "==> [1/5] Login no ECR..."
aws ecr get-login-password --region "$REGION" --profile default | \
    $DOCKER login --username AWS --password-stdin "$ECR_REGISTRY"

echo ""
echo "==> [2/5] Build vertify-server..."
$DOCKER build \
    -t "$ECR_REGISTRY/vertify/vertify-server:$TAG" \
    "$REPO_ROOT/vertify-server"

echo ""
echo "==> [3/5] Push vertify-server..."
$DOCKER push "$ECR_REGISTRY/vertify/vertify-server:$TAG"

echo ""
echo "==> [4/5] Build design-studio (Angular — pode demorar)..."
$DOCKER build \
    -t "$ECR_REGISTRY/vertify/design-studio:$TAG" \
    "$REPO_ROOT/design-studio"

echo ""
echo "==> [5/5] Push design-studio..."
$DOCKER push "$ECR_REGISTRY/vertify/design-studio:$TAG"

echo ""
echo "✓ Imagens enviadas para o ECR com sucesso."
echo "  $ECR_REGISTRY/vertify/vertify-server:$TAG"
echo "  $ECR_REGISTRY/vertify/design-studio:$TAG"
