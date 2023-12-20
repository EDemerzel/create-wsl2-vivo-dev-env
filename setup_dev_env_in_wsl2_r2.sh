#!/bin/bash

# Exit script on error
set -e

cd ~

# Check if script is running with sudo privileges
# EUID (Effective User ID) is a variable that contains the user ID of the user currently executing the script
# If EUID is not equal to 0 (root user's ID), the script is not being run with root privileges
# if [ "$EUID" -ne 0 ]; then
#     echo "Please run as root"
#     exit
# fi

# Update the list of available packages from the remote repositories
# Upgrade all the installed packages to their latest versions
# Install lsb-release, a utility for printing LSB (Linux Standard Base) information
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y lsb-release

# Store the Ubuntu codename and release number in variables
# Ex. lsb_release -rs prints the release number of the currently installed distribution
LSB_RELEASE_CS=$(lsb_release -cs)
LSB_RELEASE_RS=$(lsb_release -rs)

# Check if script is running on Ubuntu 18.04
if [ "$LSB_RELEASE_RS" != "18.04" ]; then
    echo "This script is designed to be run on Ubuntu 18.04"
    exit
fi

# Check the system architecture
ARCHITECTURE=$(uname -m)

if [ "$ARCHITECTURE" = "x86_64" ]; then
    echo "This system is amd64."
elif [ "$ARCHITECTURE" = "arm64" ]; then
    echo "This system is ARM. This script is designed to be run on amd64 systems."
    exit
else
    echo "This system's architecture is not recognized. This script is designed to be run on amd64 systems."
    exit
fi

# Install various packages needed for the script
# ca-certificates: common CA certificates
# curl: tool to transfer data from or to a server
# apt-transport-https: package transport for APT over https
# gnupg: GNU privacy guard - a free PGP replacement
# dirmngr: server for managing certificate revocation lists
# software-properties-common: manage the repositories you install software from
# build-essential: reference for all the packages needed to compile a Debian package
# gnupg-curl: GNU privacy guard (cURL helpers)
# libssl-dev: development files for the OpenSSL library
# libffi-dev: development files for the Foreign Function Interface library
# wget: utility to retrieve files from the web
# nano: command-line text editor
sudo apt-get install -y ca-certificates curl apt-transport-https gnupg dirmngr software-properties-common build-essential gnupg-curl libssl-dev libffi-dev wget nano

# Install git-all, which includes all sub-packages, allowing things like gitk to work.
sudo add-apt-repository ppa:git-core/ppa
sudo apt-get update
sudo apt-get install -y git-all

# Import the Microsoft GPG key using curl and gpg
curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg >/dev/null

# Add the Azure CLI repository to the list of apt sources
# Update the list of available packages from the remote repositories that were added
# Install the Azure CLI
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $LSB_RELEASE_CS main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
sudo apt-get update
sudo apt-get install -y azure-cli

# Add the .NET Core repository to the list of apt sources
# Update the list of available packages from the remote repositories that were added
# Install .NET Core SDKs
sudo apt-get install -y liblttng-ust0 libcurl4 libssl1.0.0 libkrb5-3 zlib1g libicu60
echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-$LSB_RELEASE_CS-prod $LSB_RELEASE_CS main" | sudo tee /etc/apt/sources.list.d/dotnetdev.list
sudo apt-get update
# sudo apt-get install -y dotnet-sdk-2.1
sudo apt-get install -y dotnet-sdk-3.1
sudo apt-get install -y dotnet-sdk-5.0

# Import the Mono GPG key and add the Mono repository to the list of apt sources
# Update the list of available packages from the remote repositories that were added
# Install Mono, a software platform to allow developers to build and run .NET applications cross-platform
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
sudo apt-add-repository "deb https://download.mono-project.com/repo/ubuntu stable-$LSB_RELEASE_CS main"
sudo apt-get update
# sudo apt install -y mono-complete

# Download the Node.js setup script
# Run the Node.js setup script
# Update the list of available packages from the remote repositories
# Install Node.js and npm
# Print the versions of Node.js and npm to verify they were installed correctly
cd ~
curl -sL https://deb.nodesource.com/setup_14.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh
sudo apt-get update
sudo apt-get install -y nodejs
node -v
npm -v

# Download the Microsoft package repository configuration file
# Install the Microsoft package repository configuration file
# Update the list of available packages from the remote repositories that were added
# Enable the "universe" repositories, which contain community-maintained free and open-source software
# Install PowerShell, a cross-platform task automation and configuration management framework
cd ~
wget -q https://packages.microsoft.com/config/ubuntu/$LSB_RELEASE_RS/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt-get update
sudo add-apt-repository universe
sudo apt-get install -y powershell

# Create a group named docker and add the current user to it
# This allows the user to run docker commands without needing sudo
# Note: You will need to logout and login before this takes effect
sudo groupadd docker
sudo usermod -aG docker ${USER}
sudo newgrp docker

# Install Python 3.8, development files for Python 3.8, the Python 3.8 virtual environment creator, and pip for Python 3
sudo apt-get install -y python3.8 python3.8-dev python3.8-venv python3-pip

# # Import the Docker GPG key and add the Docker repository to the list of apt sources
# # Import the Kubernetes GPG key and add the Kubernetes repository to the list of apt sources
# # Update the list of available packages from the remote repositories that were added
# # Install Docker CE (Community Edition) and containerd, a runtime for running and managing containers
# # Install kubectl, a command-line tool for controlling Kubernetes clusters
# # Install docker-compose using pip
# cd ~
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
# sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $LSB_RELEASE_CS stable"
# curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
# echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
# sudo apt-get update
# sudo apt-get install -y docker-ce containerd.io
# sudo apt-get install -y kubectl
# pip3 install docker-compose

# Install Docker CE and Docker Compose
cd ~
sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $LSB_RELEASE_CS stable"
sudo apt-get update
apt-cache policy docker-ce
sudo apt-get install docker-ce
sudo systemctl status docker
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version

# Install Kubernetes
cd ~
sudo apt-get update
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# Install the default Java Development Kit (JDK), which is currently OpenJDK 11
sudo apt-get install -y default-jdk

# Install Maven, a build automation tool used primarily for Java projects.
sudo apt-get install -y maven

# Install Tomcat 9 and its related packages. Tomcat is an open-source implementation of the Java Servlet, JavaServer Pages, Java Expression Language and Java WebSocket technologies.
# Add the current user to the tomcat group. This can provide the user with additional permissions for managing Tomcat.
sudo apt-get install -y tomcat9 tomcat9-admin tomcat9-common tomcat9-docs tomcat9-examples tomcat9-user
sudo usermod -aG tomcat ${USER}
sudo newgrp tomcat

# Create a new Tomcat 9 instance named 'scholars' and start it.
cd ~
tomcat9-instance-create scholars
cp /etc/tomcat9/Catalina/localhost/* ~/scholars/conf/Catalina/localhost
~/scholars/bin/startup.sh

# Install the SSH server package.
# Generate SSH keys for the SSH server.
sudo apt-get install -y ssh
sudo /usr/bin/ssh-keygen -A

# Create SSH keys for the current user's account. This will allow the user to SSH into their own account.
cd ~
ssh-keygen
cd ~/.ssh
cp id_rsa authorized_keys
cd ~

# Download and install Solr, a popular open-source search platform built on Apache Lucene.
# NOTE: This does include the SOLR-15871: Update Log4J to 2.17.1.
cd /opt
wget https://archive.apache.org/dist/lucene/solr/8.11.2/solr-8.11.2.tgz
tar xzf solr-8.11.2.tgz solr-8.11.2/bin/install_solr_service.sh --strip-components=2
sudo bash ./install_solr_service.sh solr-8.11.2.tgz

# Stop, start, and check the status of the Solr service.
# Create a new Solr core named 'vivocore' using the data_driven_schema_configs configuration.
# Add the current user to the solr group. This can provide the user with additional permissions for managing Solr.
sudo service solr stop
sudo service solr start
sudo service solr status
sudo su - solr -c "/opt/solr/bin/solr create -c vivocore -n data_driven_schema_configs"
sudo usermod -aG solr ${USER}
sudo newgrp solr

# Clone the vivo-solr repository from GitHub. This repository contains the Solr configuration files for the VIVO project.
# Stop the Solr service.
# Remove the existing vivocore Solr core.
# Copy the vivocore Solr core from the cloned repository to the Solr data directory.
# Change the owner of the vivocore Solr core to the solr user.
cd ~
mkdir repos
cd repos
git clone https://github.com/vivo-project/vivo-solr.git
sudo service solr stop
sudo rm -rv /var/solr/data/vivocore
sudo cp -r ~/repos/vivo-solr/vivocore /var/solr/data/vivocore
sudo chown -R solr:solr /var/solr/data/
cd ~

# clone VIVO repos
cd ~
cd repos
git clone https://github.com/vivo-project/VIVO.git
git clone https://github.com/vivo-project/Vitro.git
git clone https://github.com/vivo-project/VIVO-languages.git
git clone https://github.com/vivo-project/Vitro-languages.git
git clone https://github.com/vivo-project/sample-data.git
cd ~

# Run a Docker container for smtp4dev, a tool for testing email sending functionality. The web interface is available at http://localhost:3000.
docker run -p 3000:80 -p 25:25 rnwood/smtp4dev:v3

# Import the MariaDB signing key and add the MariaDB repository to the list of apt sources.
# Update the list of available packages from the remote repositories that were added
# Install MariaDB server.
sudo apt-key adv --fetch-keys "https://mariadb.org/mariadb_release_signing_key.asc"
sudo add-apt-repository "deb [arch=amd64] http://nyc2.mirrors.digitalocean.com/mariadb/repo/10.5/ubuntu $LSB_RELEASE_CS main"
sudo apt-get update
sudo apt-get install -y mariadb-server

# Start the SSH, Docker, Solr, and MariaDB services. Note that Tomcat cannot be started as a service in WSL due to a limitation with systemd.
sudo service ssh start
sudo service docker start
sudo service solr start
sudo service mariadb start

# Add commands to start the SSH, Docker, Solr, and MariaDB services to the .profile file. This will ensure that these services are started whenever a new shell session is started.
# Add a command to start the scholars Tomcat instance to the .profile file.
# Add commands to update the list of available packages, upgrade all installed packages to their latest versions, and remove packages that were automatically installed to satisfy dependencies for other packages and are now no longer needed to the .profile file.
echo 'DOTNET_CLI_TELEMETRY_OPTOUT=1' >> .profile
echo 'sudo service ssh start' >> .profile
echo 'sudo service docker start' >> .profile
echo 'sudo service solr start' >> .profile
echo 'docker run -d -p 3000:80 -p 25:25 rnwood/smtp4dev:v3' >> .profile
echo 'sudo service mariadb start' >> .profile
echo '~/scholars/bin/startup.sh' >> .profile
echo 'sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get autoremove -y' >> .profile

# Remove packages that were automatically installed to satisfy dependencies for other packages and are now no longer needed
sudo apt-get autoremove -y

# Change the working directory to the home directory.
cd ~
