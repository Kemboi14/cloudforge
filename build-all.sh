#!/bin/bash
echo "Building all CloudForge images..."

# Build auth service
echo "Building auth service..."
cd services/auth
podman build -t localhost/cloudforge-auth:latest .
cd ../..

# Build users service
echo "Building users service..."
cd services/users
podman build -t localhost/cloudforge-users:latest .
cd ../..

# Build frontend
echo "Building frontend..."
cd services/frontend
podman build -t localhost/cloudforge-frontend:latest .
cd ../..

echo "All images built successfully!"
podman images | grep cloudforge
