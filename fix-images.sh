#!/bin/bash
echo "Fixing image availability for k3s..."

# Push images to k3s container registry
echo "Making images available to k3s..."

# Save images from Podman
echo "Saving images from Podman..."
podman save localhost/cloudforge-auth:latest -o auth-image.tar
podman save localhost/cloudforge-users:latest -o users-image.tar
podman save localhost/cloudforge-frontend:latest -o frontend-image.tar

# Load images into k3s
echo "Loading images into k3s..."
sudo k3s ctr images import auth-image.tar
sudo k3s ctr images import users-image.tar
sudo k3s ctr images import frontend-image.tar

# Clean up tar files
rm -f auth-image.tar users-image.tar frontend-image.tar

# List available images
echo "Available images in k3s:"
sudo k3s ctr images ls

# Restart deployments to use the new images
echo "Restarting deployments..."
sudo k3s kubectl rollout restart deployment/auth-deployment -n cloudforge
sudo k3s kubectl rollout restart deployment/users-deployment -n cloudforge
sudo k3s kubectl rollout restart deployment/frontend-deployment -n cloudforge

echo "Waiting for pods to be ready..."
sudo k3s kubectl wait --for=condition=available --timeout=300s deployment/auth-deployment -n cloudforge
sudo k3s kubectl wait --for=condition=available --timeout=300s deployment/users-deployment -n cloudforge
sudo k3s kubectl wait --for=condition=available --timeout=300s deployment/frontend-deployment -n cloudforge

echo "Image fix completed!"
