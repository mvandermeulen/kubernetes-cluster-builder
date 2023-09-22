#!/bin/bash

# -------- PREPARE TO INSTALL THE DOCKER ENGINE

# install required apt packages
sudo apt-get install -y ca-certificates curl gnupg

# add docker’s official gpg key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# set up the repository
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# update the apt packages
sudo apt-get update

# -------- INSTALL THE DOCKER ENGINE

# install the latest version
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# creating the docker group and adding the user
sudo groupadd docker
sudo usermod -aG docker "$1"

# restart and enable docker services to start on boot-up
sudo systemctl stop docker.service
sudo systemctl start docker.service
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
