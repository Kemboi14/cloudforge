#!/bin/bash
echo "Applying fixed deployments..."

# Apply updated deployments
echo "Applying auth deployment..."
sudo k3s kubectl apply -f k8s/auth-deployment.yaml

echo "Applying users deployment..."
sudo k3s kubectl apply -f k8s/users-deployment.yaml

echo "Applying frontend deployment..."
sudo k3s kubectl apply -f k8s/frontend-deployment.yaml

echo "Waiting for deployments to be ready..."
sudo k3s kubectl wait --for=condition=available --timeout=300s deployment/auth-deployment -n cloudforge
sudo k3s kubectl wait --for=condition=available --timeout=300s deployment/users-deployment -n cloudforge
sudo k3s kubectl wait --for=condition=available --timeout=300s deployment/frontend-deployment -n cloudforge

echo "Deployment completed successfully!"
echo ""
echo "=== Final Pod Status ==="
sudo k3s kubectl get pods -n cloudforge
echo ""
echo "=== Services ==="
sudo k3s kubectl get services -n cloudforge
echo ""
echo "=== Access URLs ==="
echo "Frontend: http://localhost:30080"
echo "Auth API: http://localhost:30080/api/auth"
echo "Users API: http://localhost:30080/api/users"
