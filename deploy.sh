#!/bin/bash
echo "Deploying CloudForge to Kubernetes..."

# Set KUBECONFIG to use k3s
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

# Wait for Kubernetes to be ready
echo "Waiting for Kubernetes cluster to be ready..."
sudo k3s kubectl wait --for=condition=ready node --all --timeout=300s

# Apply namespace
echo "Applying namespace..."
sudo k3s kubectl apply -f k8s/namespace.yaml

# Apply ConfigMaps and Secrets
echo "Applying ConfigMaps and Secrets..."
sudo k3s kubectl apply -f k8s/configmap.yaml
sudo k3s kubectl apply -f k8s/secrets.yaml

# Apply deployments and services
echo "Applying deployments and services..."
sudo k3s kubectl apply -f k8s/auth-deployment.yaml
sudo k3s kubectl apply -f k8s/auth-service.yaml
sudo k3s kubectl apply -f k8s/users-deployment.yaml
sudo k3s kubectl apply -f k8s/users-service.yaml
sudo k3s kubectl apply -f k8s/frontend-deployment.yaml
sudo k3s kubectl apply -f k8s/frontend-service.yaml

# Apply ingress
echo "Applying ingress..."
sudo k3s kubectl apply -f k8s/ingress.yaml

# Wait for deployments to be ready
echo "Waiting for deployments to be ready..."
sudo k3s kubectl wait --for=condition=available --timeout=300s deployment/auth-deployment -n cloudforge
sudo k3s kubectl wait --for=condition=available --timeout=300s deployment/users-deployment -n cloudforge
sudo k3s kubectl wait --for=condition=available --timeout=300s deployment/frontend-deployment -n cloudforge

echo "Deployment completed successfully!"
echo ""
echo "=== Deployment Status ==="
sudo k3s kubectl get pods -n cloudforge
echo ""
echo "=== Services ==="
sudo k3s kubectl get services -n cloudforge
echo ""
echo "=== Access URLs ==="
echo "Frontend: http://localhost:30080"
echo "API: http://localhost:30080/api"
