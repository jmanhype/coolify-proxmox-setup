#!/bin/bash

# Installs Coolify platform

set -e

echo "🚀 Installing Coolify..."

# Check if Docker is running
if ! systemctl is-active --quiet docker; then
    echo "❌ Docker is not running! Please install Docker first."
    exit 1
fi

# Install Coolify
echo "📥 Downloading and installing Coolify..."
curl -fsSL https://cdn.coollabs.io/coolify/install.sh | bash

# Wait for Coolify to start
echo "⏳ Waiting for Coolify to start..."
sleep 20

# Check if Coolify is running
if docker ps | grep -q coolify; then
    echo "✅ Coolify installed successfully!"
    
    # Show running containers
    echo ""
    echo "📦 Running containers:"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    
    # Get Coolify logs
    echo ""
    echo "📋 Recent Coolify logs:"
    docker logs coolify --tail 20 2>&1 | grep -E "(started|listening|ready)" || true
else
    echo "❌ Coolify container is not running!"
    echo ""
    echo "Checking Docker logs..."
    docker ps -a | grep coolify
    docker logs coolify --tail 50
    exit 1
fi

echo ""
echo "🚀 Coolify installation complete!"