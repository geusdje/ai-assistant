#!/bin/bash
# EC2 launch template user data: runs once when a new instance boots.
# Installs Docker and the CodeDeploy agent so CodeDeploy can deploy to it.
set -euxo pipefail

REGION=us-east-2

dnf install -y docker ruby wget
systemctl enable --now docker  # start Docker now and on every boot

# CodeDeploy agent installer comes from the region's CodeDeploy bucket
cd /tmp
wget -q "https://aws-codedeploy-$REGION.s3.$REGION.amazonaws.com/latest/install"
chmod +x install
./install auto
systemctl enable --now codedeploy-agent
