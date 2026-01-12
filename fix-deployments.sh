#!/bin/bash
echo "Fixing deployment image pull policies..."

# Update deployments to use ImagePullPolicy: Never
echo "Updating auth deployment..."
sudo k3s kubectl patch deployment auth-deployment -n cloudforge -p '{"spec":{"template":{"spec":{"containers":[{"name":"auth","imagePullPolicy":"Never"}]}}}'

echo "Updating users deployment..."
sudo k3s kubectl patch deployment users-deployment -n cloudforge -p '{"spec":{"template":{"spec":{"containers":[{"name":"users","imagePullPolicy":"Never"}]}}}'

echo "Updating frontend deployment..."
sudo k3s kubectl patch deployment frontend-deployment -n cloudforge -p '{"spec":{"template":{"spec":{"containers":[{"name":"frontend","imagePullPolicy":"Never"}]}}}'

echo "Waiting for deployments to restart..."
sudo k3s kubectl rollout status deployment/auth-deployment -n cloudforge --timeout=300s
sudo k3s kubectl rollout status deployment/users-deployment -n cloudforge --timeout=300s
sudo k3s kubectl rollout status deployment/frontend-deployment -n cloudforge --timeout=300s

echo "Checking pod status..."
sudo k3s kubectl get pods -n cloudforge
