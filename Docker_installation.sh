#!/bin/bash

# Prompt for target server details
read -p "Enter target server IP/hostname: " TARGET_IP
read -p "Enter target server username: " TARGET_USER
read -p "Enter path to your SSH private key: " SSH_KEY

# Convert Windows path to POSIX format (for Git Bash compatibility)
SSH_KEY=$(echo "$SSH_KEY" | sed 's#\\#/#g' | sed 's#C:#/c#g')

# Check if the SSH key exists
if [ ! -f "$SSH_KEY" ]; then
    echo "❌ Error: SSH key not found at '$SSH_KEY'."
    exit 1
fi

# Establish SSH connection, run commands, and keep the session open
ssh -t -i "$SSH_KEY" "$TARGET_USER@$TARGET_IP" << 'EOF'
#!/bin/bash
set -e  # Exit on error for better debugging

# Update and install Docker
sudo apt update && sudo apt install -y docker.io

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Verify Docker installation
docker --version

# Keep SSH session active
exec bash
EOF

# Final message (only runs if SSH exits)
echo "✅ Docker installation completed. You are now inside the target server."

ssh -t -i "$SSH_KEY" "$TARGET_USER@$TARGET_IP" 
