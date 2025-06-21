#!/bin/bash

# Installs Tailscale for secure remote deployment

set -e

echo "🔐 Installing Tailscale..."

# Install Tailscale
curl -fsSL https://tailscale.com/install.sh | sh

# Enable IP forwarding for Tailscale
echo 'net.ipv4.ip_forward = 1' | tee -a /etc/sysctl.conf
echo 'net.ipv6.conf.all.forwarding = 1' | tee -a /etc/sysctl.conf
sysctl -p /etc/sysctl.conf

echo ""
echo "🚀 Starting Tailscale..."
echo ""
echo "You'll need to authenticate with your Tailscale account."
echo "Run: tailscale up --ssh"
echo ""
echo "After authentication, your container will be accessible via Tailscale network."
echo ""
echo "For the complete VPS deployment guide, see:"
echo "https://pywkt.com/post/20250130-self-host-coolify-on-proxmox-lxc-and-deploy-to-remote-vps"