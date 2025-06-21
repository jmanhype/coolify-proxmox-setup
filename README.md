# Coolify Proxmox Setup

Automated setup scripts for running Coolify in a Proxmox LXC container with proper Docker support.

## 🌌 AI Website Singularity Architecture

This repository is designed to support autonomous website generation and deployment through AI agents.

## Quick Start

### On Proxmox Host

1. Clone this repository:
```bash
git clone https://github.com/yourusername/coolify-proxmox-setup.git
cd coolify-proxmox-setup
```

2. Create the LXC container:
```bash
./scripts/create-container.sh
```

### Inside the Container

1. Clone this repository:
```bash
git clone https://github.com/yourusername/coolify-proxmox-setup.git
cd coolify-proxmox-setup
```

2. Run the setup:
```bash
./setup.sh
```

## What This Does

1. Creates a privileged LXC container with Docker support
2. Installs Docker with proper overlay2 storage driver
3. Installs Coolify platform
4. Fixes networking issues common with LXC containers
5. Optionally sets up Tailscale for secure remote deployment

## Scripts Included

- `setup.sh` - Main setup script (run inside container)
- `scripts/create-container.sh` - Creates Proxmox LXC container
- `scripts/install-docker.sh` - Docker installation
- `scripts/install-coolify.sh` - Coolify installation
- `scripts/fix-networking.sh` - Network troubleshooting
- `scripts/install-tailscale.sh` - Tailscale setup (optional)

## Requirements

- Proxmox VE 6.x or later
- Debian 12 CT template
- At least 6GB RAM and 60GB disk for the container
- Network bridge configured in Proxmox

## Architecture

```
┌─────────────────────────────────────────────┐
│           AI CONTROL PLANE                  │
│  (Your AI Agents & Orchestration)           │
└─────────────────┬───────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────┐
│         COOLIFY ON PROXMOX LXC              │
│  - Build & Deploy Automation                │
│  - Container Management                     │
│  - SSL/Domain Management                    │
└─────────────────┬───────────────────────────┘
                  │
                  ▼ (via Tailscale)
┌─────────────────────────────────────────────┐
│          REMOTE VPS FLEET                   │
│  - Production Websites                      │
│  - Auto-scaled Resources                    │
│  - Global Distribution                      │
└─────────────────────────────────────────────┘
```

## Troubleshooting

If Coolify is not accessible:

1. Check if it's running: `docker ps | grep coolify`
2. Check network binding: `ss -tlnp | grep 8000`
3. Try the networking fix: `./scripts/fix-networking.sh`
4. Use SSH tunnel as workaround: `ssh -L 8000:localhost:8000 root@proxmox-host`

## Advanced Setup

For production deployments with Tailscale and remote VPS, see:
[Full Guide](https://pywkt.com/post/20250130-self-host-coolify-on-proxmox-lxc-and-deploy-to-remote-vps)

## License

MIT