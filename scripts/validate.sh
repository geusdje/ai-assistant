#!/usr/bin/env bash
# CodeDeploy ValidateService: fail the deployment if the app isn't healthy.
set -euo pipefail

# Health check: try up to 15 times, 2 seconds apart (~30s total)
for _ in $(seq 1 15); do
  # App answered: remove images no container uses and report success
  if curl -fsS http://localhost/health >/dev/null; then
    docker image prune -af >/dev/null
    echo "Healthy"
    exit 0
  fi
  sleep 2  # not up yet, wait and try again
done

# App never came up: print its logs and fail (CodeDeploy rolls back)
echo "Health check failed" >&2
docker logs ai-assistant >&2 || true
exit 1
