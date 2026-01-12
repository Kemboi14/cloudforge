#!/bin/bash
echo "=== Debugging CloudForge Pods ==="
echo ""

echo "=== Pod Status ==="
sudo k3s kubectl get pods -n cloudforge
echo ""

echo "=== Pod Details ==="
for pod in $(sudo k3s kubectl get pods -n cloudforge -o jsonpath='{.items[*].metadata.name}'); do
    echo "--- Pod: $pod ---"
    sudo k3s kubectl describe pod $pod -n cloudforge
    echo ""
    echo "=== Logs for $pod ==="
    sudo k3s kubectl logs $pod -n cloudforge
    echo ""
done
