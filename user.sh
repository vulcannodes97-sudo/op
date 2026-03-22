#!/bin/bash

set -e
history -c && rm -f ~/.bash_history && clear
echo "⚡ VPS Auto Setup Starting..."

# Detect if running as root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Run as root: use 'sudo -i' first"
  exit 1
fi

# 1. Enable root login (SSH)
echo "🔐 Enabling root SSH login..."
if [ -f /etc/ssh/sshd_config ]; then
  sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config || true
  sed -i 's/^PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config || true
  
  systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null || service ssh restart || true
fi

# 2. Change root password
echo "🔑 Changing root password..."
echo "root:1234" | chpasswd

# 3. Install dependencies
echo "📦 Installing dependencies..."
apt-get update -y
apt-get install -y curl gnupg lsb-release

# 4. Install Cloudflared
echo "☁️ Installing Cloudflared..."

mkdir -p /usr/share/keyrings

curl -fsSL https://pkg.cloudflare.com/cloudflare-public-v2.gpg \
| tee /usr/share/keyrings/cloudflare-public-v2.gpg >/dev/null

echo "deb [signed-by=/usr/share/keyrings/cloudflare-public-v2.gpg] https://pkg.cloudflare.com/cloudflared any main" \
> /etc/apt/sources.list.d/cloudflared.list

apt-get update -y
apt-get install -y cloudflared

echo "🔗 Setting up Cloudflare Tunnel..."
cloudflared service install eyJhIjoiYmI3Mzg1ZmVmZWQxNjViNzdiMDA4ODU1YmM0NTc2OWMiLCJ0IjoiNjIzMWY0ZTYtYzJmMS00NDM1LWJkY2EtZTk1M2NhOWQ0NGJlIiwicyI6Ik1ETmxaalU1T0dJdE1UVXlZaTAwTm1Zd0xXSmlOalF0T0RJMU56VTFORGd5WlRkaSJ9

# 5. Install Tailscale
echo "🧩 Installing Tailscale..."

curl -fsSL https://tailscale.com/install.sh | sh

tailscale up \
--auth-key=tskey-auth-k7ygTfXeMm11CNTRL-Gct6xZy7Pwh8VvYfdbftvhnsKdZmPbpZ \
--advertise-exit-node || echo "⚠️ Tailscale failed (maybe key expired)"

echo "✅ ALL DONE!"
