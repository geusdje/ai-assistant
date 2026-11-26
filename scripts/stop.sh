#!/usr/bin/env bash
# CodeDeploy ApplicationStop: remove the running container (if any).
docker rm -f ai-assistant >/dev/null 2>&1 || true
