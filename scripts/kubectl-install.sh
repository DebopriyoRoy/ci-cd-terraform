#!/bin/bash

echo "========================================="
echo "         kubectl Install Script          "
echo "========================================="

# Download kubectl binary
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.35.2/2026-02-27/bin/linux/amd64/kubectl

# Download checksum
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.35.2/2026-02-27/bin/linux/amd64/kubectl.sha256

# Verify checksum
echo "[*] Verifying checksum..."
sha256sum -c kubectl.sha256

# Make executable
chmod +x ./kubectl

# Move to /usr/local/bin so ALL users (including jenkins) can access it
mv ./kubectl /usr/local/bin/kubectl

# Verify installation
echo "[*] Verifying kubectl..."
kubectl version --client

echo "kubectl installed successfully!"