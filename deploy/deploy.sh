#!/usr/bin/env bash
# Runs on the EC2 host after CI uploads the code: build the image and swap the container.
set -euo pipefail

APP_DIR="${APP_DIR:-$HOME/ai-assistant}"
APP_VERSION="${APP_VERSION:-manual}"
NAME=ai-assistant

# First deploy on a fresh Amazon Linux host: install Docker
if ! command -v docker >/dev/null 2>&1; then
  sudo dnf install -y docker
fi
sudo systemctl enable --now docker

cd "$APP_DIR"
sudo docker build --build-arg APP_VERSION="$APP_VERSION" -t "$NAME:latest" .
sudo docker rm -f "$NAME" >/dev/null 2>&1 || true
sudo docker run -d --name "$NAME" --restart unless-stopped -p 80:8000 "$NAME:latest"

# Fail the deploy if the new container doesn't come up healthy
for _ in $(seq 1 15); do
  if curl -fsS http://localhost/health >/dev/null; then
    sudo docker image prune -f >/dev/null
    echo "Deployed $APP_VERSION"
    exit 0
  fi
  sleep 2
done

echo "Health check failed for $APP_VERSION" >&2
sudo docker logs "$NAME" >&2 || true
exit 1
