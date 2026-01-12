#!/bin/bash
echo "=== Checking Pod Logs ==="
echo ""

# Get all pod names
pods=$(sudo k3s kubectl get pods -n cloudforge -o jsonpath='{.items[*].metadata.name}')

for pod in $pods; do
    echo "=== Logs for $pod ==="
    sudo k3s kubectl logs $pod -n cloudforge --tail=20
    echo ""
    
    # Check if pod is crashing
    status=$(sudo k3s kubectl get pod $pod -n cloudforge -o jsonpath='{.status.phase}')
    if [ "$status" = "Failed" ] || [ "$status" = "CrashLoopBackOff" ]; then
        echo "=== Previous logs for $pod ==="
        sudo k3s kubectl logs $pod -n cloudforge --previous --tail=20
        echo ""
    fi
done

echo "=== Pod Events ==="
sudo k3s kubectl get events -n cloudforge --sort-by='.lastTimestamp' | tail -20
