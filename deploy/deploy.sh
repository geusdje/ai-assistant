#!/usr/bin/env bash
# Runs on the EC2 host after CI uploads the code: build the image and swap the container.
set -euo pipefail  # stop on any error

APP_DIR="${APP_DIR:-$HOME/ai-assistant}"  # where CI unpacked the code
APP_VERSION="${APP_VERSION:-manual}"      # commit id passed in by CI
NAME=ai-assistant                         # image and container name

# First deploy on a fresh Amazon Linux host: install Docker
if ! command -v docker >/dev/null 2>&1; then
  sudo dnf install -y docker
fi
sudo systemctl enable --now docker  # start Docker now and on every boot

cd "$APP_DIR"

# Build the new image
sudo docker build --build-arg APP_VERSION="$APP_VERSION" -t "$NAME:latest" .

# Replace the old container with the new one (host port 80 -> app port 8000)
sudo docker rm -f "$NAME" >/dev/null 2>&1 || true
sudo docker run -d --name "$NAME" --restart unless-stopped -p 80:8000 "$NAME:latest"

# Health check: try up to 15 times, 2 seconds apart (~30s total)
for _ in $(seq 1 15); do
  # App answered: clean up old images and report success
  if curl -fsS http://localhost/health >/dev/null; then
    sudo docker image prune -f >/dev/null
    echo "Deployed $APP_VERSION"
    exit 0
  fi
  sleep 2  # not up yet, wait and try again
done

# App never came up: print its logs and fail the deploy
echo "Health check failed for $APP_VERSION" >&2
sudo docker logs "$NAME" >&2 || true
exit 1
