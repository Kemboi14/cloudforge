#!/bin/bash
echo "=== CloudForge Platform Status ==="
echo ""

echo "=== Pods ==="
sudo k3s kubectl get pods -n cloudforge
echo ""

echo "=== Services ==="
sudo k3s kubectl get services -n cloudforge
echo ""

echo "=== Ingress ==="
sudo k3s kubectl get ingress -n cloudforge
echo ""

echo "=== Nodes ==="
sudo k3s kubectl get nodes
echo ""

echo "=== Access URLs ==="
echo "Frontend: http://localhost:30080"
echo "Auth API: http://localhost:30080/api/auth"
echo "Users API: http://localhost:30080/api/users"
