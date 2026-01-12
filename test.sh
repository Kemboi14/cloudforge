#!/bin/bash
echo "Testing script execution"
echo "Current directory: $(pwd)"
echo "Podman version:"
podman --version
echo "Building auth service..."
cd services/auth
podman build -t localhost/cloudforge-auth:latest .
echo "Build completed"
