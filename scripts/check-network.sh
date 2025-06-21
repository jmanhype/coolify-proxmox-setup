#!/bin/bash

# Checks network configuration and Coolify accessibility

echo "🌐 Checking network configuration..."

# Get container IP
CONTAINER_IP=$(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
echo "Container IP: $CONTAINER_IP"

# Check what's listening on port 8000
echo ""
echo "📡 Checking port 8000..."
if ss -tlnp | grep -q :8000; then
    echo "✅ Port 8000 is listening:"
    ss -tlnp | grep :8000
else
    echo "❌ Nothing listening on port 8000"
fi

# Check Docker port mapping
echo ""
echo "🐳 Docker port mappings:"
docker ps --format "table {{.Names}}\t{{.Ports}}" | grep -E "coolify|8000" || echo "No Coolify ports found"

# Test local connectivity
echo ""
echo "🧪 Testing local connectivity..."
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8000 | grep -q "200\|301\|302"; then
    echo "✅ Coolify is accessible locally"
else
    echo "❌ Coolify is NOT accessible locally"
fi

# Check Coolify environment
echo ""
echo "⚙️  Coolify environment:"
docker exec coolify env 2>/dev/null | grep -E 'APP_URL|SERVER_URL|URL' || echo "Could not get Coolify environment"

# Network summary
echo ""
echo "📋 Network Summary:"
echo "- Container IP: $CONTAINER_IP"
echo "- Coolify should be accessible at: http://$CONTAINER_IP:8000"
echo ""
echo "If not accessible from outside, run: ./scripts/fix-networking.sh"