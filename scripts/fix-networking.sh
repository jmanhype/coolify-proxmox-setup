#!/bin/bash

# Fixes common networking issues with Coolify in LXC containers

set -e

echo "🔧 Fixing Coolify networking..."

# Method 1: Check and fix Coolify binding
echo ""
echo "📌 Method 1: Checking Coolify binding configuration..."

# Check current binding
CURRENT_BINDING=$(ss -tlnp | grep :8000 | awk '{print $4}')
echo "Current binding: $CURRENT_BINDING"

if echo "$CURRENT_BINDING" | grep -q "127.0.0.1\|localhost"; then
    echo "⚠️  Coolify is binding to localhost only. Fixing..."
    
    # Try to update Coolify environment
    docker exec coolify bash -c '
    if [ -f /app/.env ]; then
        cp /app/.env /app/.env.backup
        sed -i "s|APP_URL=http://localhost|APP_URL=http://0.0.0.0|g" /app/.env
        sed -i "s|APP_URL=http://127.0.0.1|APP_URL=http://0.0.0.0|g" /app/.env
    fi
    ' 2>/dev/null || echo "Could not modify Coolify environment"
    
    # Restart Coolify
    echo "🔄 Restarting Coolify..."
    docker restart coolify
    sleep 15
fi

# Method 2: iptables port forwarding
echo ""
echo "📌 Method 2: Setting up iptables port forwarding..."

# Enable IP forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward
sysctl -w net.ipv4.ip_forward=1

# Get Coolify container IP
COOLIFY_IP=$(docker inspect coolify | grep -i '"IPAddress"' | head -n 1 | grep -oP '(?<="IPAddress": ")[^"]*')

if [ ! -z "$COOLIFY_IP" ]; then
    echo "Coolify container IP: $COOLIFY_IP"
    
    # Add iptables rules
    iptables -t nat -A PREROUTING -p tcp --dport 8000 -j DNAT --to-destination $COOLIFY_IP:8000 2>/dev/null || true
    iptables -t nat -A POSTROUTING -j MASQUERADE 2>/dev/null || true
    
    echo "✅ Port forwarding rules added"
fi

# Method 3: Docker proxy workaround
echo ""
echo "📌 Method 3: Creating Docker proxy..."

# Stop any existing proxy
docker stop coolify-proxy 2>/dev/null || true
docker rm coolify-proxy 2>/dev/null || true

# Create a simple nginx proxy
docker run -d \
    --name coolify-proxy \
    --restart unless-stopped \
    -p 8000:80 \
    -e NGINX_HOST=coolify \
    -e NGINX_PORT=8000 \
    --link coolify:coolify \
    nginx:alpine \
    sh -c 'echo "server { listen 80; location / { proxy_pass http://coolify:8000; proxy_set_header Host \$host; } }" > /etc/nginx/conf.d/default.conf && nginx -g "daemon off;"' 2>/dev/null || echo "Could not create proxy"

# Final check
echo ""
echo "🧪 Final network check..."
sleep 5

CONTAINER_IP=$(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

if curl -s -o /dev/null -w "%{http_code}" http://localhost:8000 | grep -q "200\|301\|302"; then
    echo "✅ Coolify is now accessible!"
    echo ""
    echo "Access Coolify at: http://$CONTAINER_IP:8000"
else
    echo "⚠️  Coolify may still not be accessible. Try SSH tunnel:"
    echo ""
    echo "From your local machine:"
    echo "ssh -L 8000:localhost:8000 root@<proxmox-host-ip>"
    echo "Then access: http://localhost:8000"
fi

# Make iptables rules persistent (optional)
if command -v netfilter-persistent &> /dev/null; then
    netfilter-persistent save
elif command -v iptables-save &> /dev/null; then
    iptables-save > /etc/iptables/rules.v4
fi

echo ""
echo "🔧 Networking fixes applied!"