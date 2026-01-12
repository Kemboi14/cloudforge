#!/bin/bash
echo "=== CloudForge Platform Final Status ==="
echo ""

echo "=== Pods ==="
sudo k3s kubectl get pods -n cloudforge
echo ""

echo "=== Services ==="
sudo k3s kubectl get services -n cloudforge
echo ""

echo "=== Recent Pod Logs ==="
for pod in $(sudo k3s kubectl get pods -n cloudforge -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n' | head -3); do
    echo "--- Recent logs for $pod ---"
    sudo k3s kubectl logs $pod -n cloudforge --tail=5 2>/dev/null || echo "No logs available"
    echo ""
done

echo "=== Access URLs ==="
echo "Frontend: http://localhost:30080"
echo "Auth API: http://localhost:30080/api/auth"
echo "Users API: http://localhost:30080/api/users"
echo ""
echo "=== GitHub Repository ==="
echo "https://github.com/Kemboi14/cloudforge.git"
