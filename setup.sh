#!/bin/bash

# Main setup script - run this inside the LXC container
# This orchestrates the entire Coolify installation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=================================================="
echo "     COOLIFY PROXMOX LXC SETUP"
echo "=================================================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Please run as root"
    exit 1
fi

# Source the configuration
if [ -f "$SCRIPT_DIR/config.env" ]; then
    source "$SCRIPT_DIR/config.env"
fi

echo "📦 Step 1: Installing Docker..."
bash "$SCRIPT_DIR/scripts/install-docker.sh"

echo ""
echo "🚀 Step 2: Installing Coolify..."
bash "$SCRIPT_DIR/scripts/install-coolify.sh"

echo ""
echo "🌐 Step 3: Checking network configuration..."
bash "$SCRIPT_DIR/scripts/check-network.sh"

echo ""
echo "🔧 Step 4: Applying network fixes if needed..."
bash "$SCRIPT_DIR/scripts/fix-networking.sh"

echo ""
echo "=================================================="
echo "✅ SETUP COMPLETE!"
echo "=================================================="
echo ""

# Get the container's IP
CONTAINER_IP=$(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

echo "Coolify should be accessible at:"
echo "👉 http://${CONTAINER_IP}:8000"
echo ""
echo "Next steps:"
echo "1. Access the Coolify dashboard"
echo "2. Create your admin account"
echo "3. Follow the onboarding process"
echo ""
echo "Optional: Install Tailscale for secure remote deployment"
echo "Run: ./scripts/install-tailscale.sh"
echo ""

# Save the IP for reference
echo "COOLIFY_URL=http://${CONTAINER_IP}:8000" > "$SCRIPT_DIR/.env"

echo "Installation details saved to .env file"