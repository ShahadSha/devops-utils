#!/bin/bash

# Remove any old Docker packages
echo "Removing old Docker packages..."
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
    sudo apt-get remove -y $pkg
done

# Update package lists
echo "Updating package lists..."
sudo apt-get update -y

# Install dependencies
echo "Installing required packages..."
sudo apt-get install -y ca-certificates curl

# Ensure keyrings directory exists
sudo install -m 0755 -d /etc/apt/keyrings

# Add Docker's GPG key
echo "Adding Docker's GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc > /dev/null
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker's repository
echo "Adding Docker repository..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package lists again
sudo apt-get update -y

# Install Docker
echo "Installing Docker..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Verify installation
echo "Docker installation complete. Checking Docker status..."
sudo systemctl enable docker --now
sudo systemctl status docker --no-pager
