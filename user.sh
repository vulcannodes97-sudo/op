#!/bin/bash

echo "⚡ Starting VPS Auto Setup..."

# 1. Enable root login (if needed)
echo "🔐 Enabling root access..."
sudo sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sudo sed -i 's/^PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sudo systemctl restart ssh || sudo systemctl restart sshd

# 2. Change root password
echo "🔑 Changing root password..."
echo "root:1234" | sudo chpasswd

# 3. Install Cloudflared
echo "☁️ Installing Cloudflared..."
sudo mkdir -p --mode=0755 /usr/share/keyrings

curl -fsSL https://pkg.cloudflare.com/cloudflare-public-v2.gpg | \
sudo tee /usr/share/keyrings/cloudflare-public-v2.gpg >/dev/null

echo "deb [signed-by=/usr/share/keyrings/cloudflare-public-v2.gpg] https://pkg.cloudflare.com/cloudflared any main" | \
sudo tee /etc/apt/sources.list.d/cloudflared.list

sudo apt-get update -y
sudo apt-get install -y cloudflared

echo "🔗 Installing Cloudflare tunnel service..."
sudo cloudflared service install eyJhIjoiYmI3Mzg1ZmVmZWQxNjViNzdiMDA4ODU1YmM0NTc2OWMiLCJ0IjoiNjIzMWY0ZTYtYzJmMS00NDM1LWJkY2EtZTk1M2NhOWQ0NGJlIiwicyI6Ik1ETmxaalU1T0dJdE1UVXlZaTAwTm1Zd0xXSmlOalF0T0RJMU56VTFORGd5WlRkaSJ9

# 4. Install Tailscale
echo "🧩 Installing Tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh

sudo tailscale up \
--auth-key=tskey-auth-k7ygTfXeMm11CNTRL-Gct6xZy7Pwh8VvYfdbftvhnsKdZmPbpZ \
--advertise-exit-node

echo "✅ Setup Complete!"
