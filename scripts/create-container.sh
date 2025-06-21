#!/bin/bash

# Creates a Proxmox LXC container configured for Coolify
# Run this ON THE PROXMOX HOST

set -e

# Default configuration
CTID=${CTID:-100}
HOSTNAME=${HOSTNAME:-coolify}
TEMPLATE=${TEMPLATE:-"local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst"}
STORAGE=${STORAGE:-"local-lvm"}
MEMORY=${MEMORY:-6144}
CORES=${CORES:-4}
DISK=${DISK:-60}
BRIDGE=${BRIDGE:-"vmbr0"}

echo "=================================================="
echo "     PROXMOX LXC CONTAINER CREATION"
echo "=================================================="
echo ""
echo "Configuration:"
echo "- Container ID: $CTID"
echo "- Hostname: $HOSTNAME"
echo "- Memory: ${MEMORY}MB"
echo "- Cores: $CORES"
echo "- Disk: ${DISK}GB"
echo "- Network: DHCP on $BRIDGE"
echo "- Type: PRIVILEGED (required for Docker)"
echo ""

# Check if container already exists
if pct status $CTID &>/dev/null; then
    echo "❌ ERROR: Container $CTID already exists!"
    echo ""
    echo "To remove it:"
    echo "  pct stop $CTID"
    echo "  pct destroy $CTID"
    exit 1
fi

# Check if template exists
if ! pveam list $STORAGE | grep -q "debian-12-standard"; then
    echo "📥 Debian 12 template not found. Downloading..."
    pveam update
    pveam download local debian-12-standard_12.7-1_amd64.tar.zst
fi

echo "📦 Creating container..."
pct create $CTID $TEMPLATE \
    --hostname $HOSTNAME \
    --memory $MEMORY \
    --cores $CORES \
    --net0 name=eth0,bridge=$BRIDGE,ip=dhcp \
    --storage $STORAGE \
    --rootfs $STORAGE:$DISK \
    --unprivileged 0 \
    --onboot 1 \
    --startup order=2

echo "⚙️  Adding Docker features..."
cat >> /etc/pve/lxc/$CTID.conf << EOF
features: keyctl=1,nesting=1
lxc.apparmor.profile: unconfined
lxc.cgroup2.devices.allow: a
lxc.cap.drop:
lxc.mount.auto: proc:rw sys:rw
EOF

echo ""
echo "✅ Container created successfully!"
echo ""
echo "📋 Configuration saved at: /etc/pve/lxc/$CTID.conf"
echo ""
echo "Next steps:"
echo "1. Start the container: pct start $CTID"
echo "2. Enter the container: pct enter $CTID"
echo "3. Install git: apt update && apt install -y git"
echo "4. Clone the setup repo:"
echo "   git clone https://github.com/yourusername/coolify-proxmox-setup.git"
echo "5. Run the setup: cd coolify-proxmox-setup && ./setup.sh"