AWX Tower Setup, Integration with GitHub, and Configuration Guide.
Just now
In the fast-paced world of DevOps, automation is the backbone of efficiency and reliability. AWX Tower serves as the open-source version of Ansible Tower, providing a powerful web-based interface to manage, schedule, and monitor Ansible playbooks. Mastering AWX Tower means gaining complete control over infrastructure automation with visibility and centralized execution.

Manually running Ansible playbooks can be manageable at first, but as environments grow more complex, automation becomes a necessity. Setting up AWX Tower on AWS provides seamless orchestration of playbooks across environments. With two EC2 instances — a Master Node for AWX Tower and a Worker Node for executing tasks — this guide walks through the setup of a scalable and automated Ansible management system.

Prerequisite:
2 EC2 instances: One as Master and the other as Worker.
Instance Type: t2.medium or higher.
OS: Ubuntu 20.04 or 22.04 recommended.
SSH Access: Ensure you can SSH into both instances.
GitHub Account & Repository.
Architecture Overview
[Master Node (AWX Tower)]
    └── AWX Tower Application
    └── Docker, Ansible, Node.js, Python
[Worker Node]
    └── Target for Playbook Execution
The Master Node will host the AWX Tower, while the Worker Node will be the target for Ansible playbooks executed via AWX.

Step 1: Execute the AWX Tower Setup Script
Run the following command on your Master Node:

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
./nstall_awx.sh <admin> <mysecurepassword>
This script performs the following:

Installs Docker, Docker Compose, Ansible, Node.js, and dependencies.
Downloads AWX Tower version 17.1.0 and sets up the environment.
Configures admin credentials and secret key in the inventory file.
Executes the Ansible playbook to install AWX Tower.
Step 2: Configure AWX Tower


1️⃣ Create Credentials

Navigate to AWX Tower → Credentials → Add
Enter the following details:
Name: GitHub-Credentials
Credential Type: Source Control
Username: <your_github_username>
Password: <your_github_personal_access_token>
Organization: Default or your preferred organization


2️⃣ Create Project

Navigate to Projects → Add
Fill in:
Name: My-AWX-Project
Source Control Type: Git
Repository URL: <your_github_repo_url>
Credential Type: Select GitHub credentials created earlier
Organization: Default
Step 3: Exchange SSH Keys
On the Master Node:

ssh-keygen -t rsa -b 4096 -C "id_rsa"
Copy the public key to the Worker Node:

ssh-copy-id -i ~/.ssh/id_rsa.pub user@worker-node-ip
Or manually:

cat ~/.ssh/id_rsa.pub | ssh user@worker-node-ip 'cat >> ~/.ssh/authorized_keys'
Step 4: Create Inventory and Job Template
Create Inventory:

Go to Inventories → Add
Name: My-Inventory
Description: AWX Worker Nodes
Organization: Default
Add Hosts:
Hostname: <worker-node-ip>
Variables: Leave empty or customize if needed
Create Job Template:

Navigate to Templates → Add → Job Template
Enter the following:
Name: Deploy Playbook
Job Type: Run
Inventory: My-Inventory
Project: My-AWX-Project
Playbook: <your_playbook.yml>
Credentials: GitHub-Credentials
Step 5: Test Your Setup

To test the setup, launch the Job Template from AWX Tower → Templates → Deploy Playbook → Launch. Verify execution and output logs.

Troubleshooting
If Docker services fail to start, check logs:
sudo journalctl -u docker.service
2. AWX Tower UI not accessible:

Verify ports are open: 8080 for AWX UI.
3. Permission issues during key exchange:

Ensure correct permissions:
chmod 600 ~/.ssh/authorized_keys
Congratulations! You have successfully set up and configured AWX Tower with a Master and Worker Node architecture.
