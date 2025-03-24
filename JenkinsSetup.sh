#!/bin/bash
 
# Function to check the success of a command

check_success() {

    if [ $? -ne 0 ]; then

        echo "Error during the previous command. Exiting."

        exit 1

    fi

}
 
echo "=== Starting Jenkins Setup ==="
 
# Update package repository

echo "Updating package repository..."

sudo apt update

check_success
 
# Install OpenJDK 21

echo "Installing OpenJDK 21..."

sudo apt install openjdk-21-jdk -y

check_success
 
# Display Java version

echo "Java version installed:"

java -version
 
# Download Jenkins keyring

echo "Downloading Jenkins keyring..."

sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

check_success
 
# Add Jenkins repository to the sources list

echo "Adding Jenkins repository to sources list..."

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

check_success
 
# Update package repository again to include Jenkins repo

echo "Updating package repository again..."

sudo apt update

check_success
 
# Install Jenkins

echo "Installing Jenkins..."

sudo apt install jenkins -y

check_success
 
# Start Jenkins service

echo "Starting Jenkins service..."

sudo systemctl start jenkins

check_success
 
# Check Jenkins service status

echo "Checking Jenkins service status..."

sudo systemctl status jenkins
 
# Allow Jenkins through the firewall

echo "Configuring firewall to allow Jenkins on port 8080..."

sudo ufw allow 8080

check_success
 
# Show current UFW status

echo "Current UFW status:"

sudo ufw status
 
# Enable UFW if it's not active

if [[ $(sudo ufw status | grep -o "inactive") ]]; then

    echo "Enabling UFW..."

    sudo ufw enable

    check_success

else

    echo "UFW is already enabled."

fi
 
# Display the initial admin password

echo "Retrieving the initial admin password for Jenkins..."

echo "Initial Admin Password for Jenkins:"

sudo cat /var/lib/jenkins/secrets/initialAdminPassword
 
echo "=== Jenkins Setup Complete ==="

#!/bin/bash
 
# Function to check the success of a command

check_success() {

    if [ $? -ne 0 ]; then

        echo "Error during the previous command. Exiting."

        exit 1

    fi

}
 
echo "=== Starting Jenkins Setup ==="
 
# Update package repository

echo "Updating package repository..."

sudo apt update

check_success
 
# Install OpenJDK 21

echo "Installing OpenJDK 21..."

sudo apt install openjdk-21-jdk -y

check_success
 
# Display Java version

echo "Java version installed:"

java -version
 
# Download Jenkins keyring

echo "Downloading Jenkins keyring..."

sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

check_success
 
# Add Jenkins repository to the sources list

echo "Adding Jenkins repository to sources list..."

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

check_success
 
# Update package repository again to include Jenkins repo

echo "Updating package repository again..."

sudo apt update

check_success
 
# Install Jenkins

echo "Installing Jenkins..."

sudo apt install jenkins -y

check_success
 
# Start Jenkins service

echo "Starting Jenkins service..."

sudo systemctl start jenkins

check_success
 
# Check Jenkins service status

echo "Checking Jenkins service status..."

sudo systemctl status jenkins
 
# Allow Jenkins through the firewall

echo "Configuring firewall to allow Jenkins on port 8080..."

sudo ufw allow 8080

check_success
 
# Show current UFW status

echo "Current UFW status:"

sudo ufw status
 
# Enable UFW if it's not active

if [[ $(sudo ufw status | grep -o "inactive") ]]; then

    echo "Enabling UFW..."

    sudo ufw enable

    check_success

else

    echo "UFW is already enabled."

fi
 
# Display the initial admin password

echo "Retrieving the initial admin password for Jenkins..."

echo "Initial Admin Password for Jenkins:"

sudo cat /var/lib/jenkins/secrets/initialAdminPassword
 
echo "=== Jenkins Setup Complete ==="

 
