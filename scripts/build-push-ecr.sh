#!/bin/bash
# Build and push vertify-server, design-studio and vertify-dashboard images to ECR
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

echo "==> [1/7] Login no ECR..."
aws ecr get-login-password --region "$REGION" --profile default | \
    $DOCKER login --username AWS --password-stdin "$ECR_REGISTRY"

echo ""
echo "==> [2/7] Build vertify-server..."
$DOCKER build \
    -t "$ECR_REGISTRY/vertify/vertify-server:$TAG" \
    "$REPO_ROOT/vertify-server"

echo ""
echo "==> [3/7] Push vertify-server..."
$DOCKER push "$ECR_REGISTRY/vertify/vertify-server:$TAG"

echo ""
echo "==> [4/7] Build design-studio (Angular — pode demorar)..."
$DOCKER build \
    -t "$ECR_REGISTRY/vertify/design-studio:$TAG" \
    "$REPO_ROOT/design-studio"

echo ""
echo "==> [5/7] Push design-studio..."
$DOCKER push "$ECR_REGISTRY/vertify/design-studio:$TAG"

echo ""
echo "==> [6/7] Build vertify-dashboard (Angular — pode demorar)..."
$DOCKER build \
    -t "$ECR_REGISTRY/vertify/vertify-dashboard:$TAG" \
    "$REPO_ROOT/vertify-dashboard"

echo ""
echo "==> [7/7] Push vertify-dashboard..."
$DOCKER push "$ECR_REGISTRY/vertify/vertify-dashboard:$TAG"

echo ""
echo "✓ Imagens enviadas para o ECR com sucesso."
echo "  $ECR_REGISTRY/vertify/vertify-server:$TAG"
echo "  $ECR_REGISTRY/vertify/design-studio:$TAG"
echo "  $ECR_REGISTRY/vertify/vertify-dashboard:$TAG"
