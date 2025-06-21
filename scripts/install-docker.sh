#!/bin/bash

# Installs Docker with proper configuration for LXC containers

set -e

echo "🐳 Installing Docker..."

# Update system
apt update && apt upgrade -y

# Install prerequisites
apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    apt-transport-https \
    software-properties-common

# Add Docker's official GPG key
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Configure Docker daemon for LXC
echo "⚙️  Configuring Docker for LXC..."
cat > /etc/docker/daemon.json << EOF
{
  "storage-driver": "overlay2",
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "default-address-pools": [
    {
      "base": "172.17.0.0/16",
      "size": 24
    }
  ]
}
EOF

# Enable and start Docker
systemctl enable docker
systemctl restart docker

# Wait for Docker to be ready
sleep 5

# Test Docker
echo "🧪 Testing Docker installation..."
if docker run --rm hello-world; then
    echo "✅ Docker installed successfully!"
else
    echo "❌ Docker test failed!"
    exit 1
fi

# Install Docker Compose standalone (optional, as plugin is already installed)
if [ ! -f /usr/local/bin/docker-compose ]; then
    echo "📦 Installing Docker Compose standalone..."
    COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
    curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

echo "🐳 Docker installation complete!"