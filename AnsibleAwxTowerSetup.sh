#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Check for admin username and password as arguments
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: ./install_awx.sh <admin_user> <admin_password>"
    exit 1
fi
ADMIN_USER="$1"
ADMIN_PASSWORD="$2"

# Update system packages
echo "Updating system packages..."
sudo apt update -y

# Install required dependencies
echo "Installing dependencies..."
sudo apt install -y python3.12-venv
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update -y
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Start and enable Docker
echo "Starting and enabling Docker..."
sudo systemctl start docker
sudo systemctl enable docker
sudo systemctl restart docker.service
sudo systemctl status docker --no-pager

# Install Docker Compose
echo "Installing Docker Compose..."
sudo apt install -y docker-compose

# Install Ansible
echo "Installing Ansible..."
sudo apt install -y ansible

# Install Node.js and npm
echo "Installing Node.js and npm..."
sudo apt install -y nodejs npm

# Install Python dependencies
echo "Installing Python dependencies..."
sudo apt install -y python3-pip git pwgen
python3 -m venv awx_venv
source awx_venv/bin/activate
pip install docker-compose==1.25.0
deactivate

# Install pipx and Docker Compose (alternative method)
sudo apt install -y pipx
pipx install docker-compose==1.25.0

# Download and extract AWX if not already present
if [ ! -d "awx-17.1.0" ]; then
    echo "Downloading and setting up AWX..."
    wget https://github.com/ansible/awx/archive/17.1.0.zip
    sudo apt install -y unzip
    unzip 17.1.0.zip
fi
cd awx-17.1.0/installer

# Set admin credentials and secret key in inventory
echo "Setting admin credentials and secret key..."
sed -i "/^#* *admin_user=/c\admin_user='$ADMIN_USER'" inventory
sed -i "/^#* *admin_password=/c\admin_password='$ADMIN_PASSWORD'" inventory

SECRET_KEY="$(pwgen -N 1 -s 30)"
sed -i "/^secret_key=/c\secret_key='$SECRET_KEY'" inventory

# Restart services
echo "Restarting necessary services..."
sudo systemctl restart getty@tty1.service
sudo systemctl restart networkd-dispatcher.service
sudo systemctl restart serial-getty@ttyS0.service
sudo systemctl restart systemd-logind.service
sudo systemctl restart unattended-upgrades.service

# Install AWX using Ansible
echo "Starting AWX installation..."
ansible-playbook -i inventory install.yml

echo "AWX installation completed successfully!"
