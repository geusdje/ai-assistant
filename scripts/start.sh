#!/usr/bin/env bash
# CodeDeploy ApplicationStart: pull the new image from ECR and run it.
set -euo pipefail

source "$(dirname "$0")/../image.env"  # IMAGE and REGION, written by CodeBuild
REGISTRY="${IMAGE%%/*}"                 # part before the first "/"

# Log in to ECR with the instance role, then pull the image
aws ecr get-login-password --region "$REGION" | docker login --username AWS --password-stdin "$REGISTRY"
docker pull "$IMAGE"

# Start the new container (host port 80 -> app port 8000)
docker rm -f ai-assistant >/dev/null 2>&1 || true
docker run -d --name ai-assistant --restart unless-stopped -p 80:8000 "$IMAGE"
