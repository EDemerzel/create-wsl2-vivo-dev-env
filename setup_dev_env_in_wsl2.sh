#!/bin/bash

# update the package manager
sudo apt-get update
sudo apt-get install -y ca-certificates curl apt-transport-https lsb-release gnupg dirmngr software-properties-common build-essential gnupg-curl
curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null

# add the dotnet core repo
AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | sudo tee /etc/apt/sources.list.d/azure-cli.list

# update the package manager
sudo apt-get update
sudo apt-get install -y azure-cli

# add the dotnet core repo
echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-bionic-prod bionic main" | sudo tee /etc/apt/sources.list.d/dotnetdev.list

# update the package manager
sudo apt-get update

# install dotnet core
sudo apt-get install -y dotnet-sdk-2.1
sudo apt-get install -y dotnet-sdk-3.1

# install mono-complete
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
sudo apt-add-repository 'deb https://download.mono-project.com/repo/ubuntu stable-bionic main'
sudo apt-get update
sudo apt install -y mono-complete

# install modejs and npm
cd ~
curl -sL https://deb.nodesource.com/setup_12.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh
sudo apt-get update
sudo apt-get install -y nodejs
nodejs -v
npm -v

# Download the Microsoft repository GPG keys
wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb

# Register the Microsoft repository GPG keys
sudo dpkg -i packages-microsoft-prod.deb

# Update the list of products
sudo apt-get update

# Enable the "universe" repositories
sudo add-apt-repository universe

# Install PowerShell
sudo apt-get install -y powershell

# update the package manager and install some prerequisites (all of these aren't technically required)
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common libssl-dev libffi-dev git wget nano

# create a group named docker and add yourself to it
#   so that we don't have to type sudo docker every time
#   note you will need to logout and login before this takes affect (which we do later)
sudo groupadd docker
sudo usermod -aG docker ${USER}
sudo newgrp docker

# add Docker key and repo
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# (optional) add kubectl key and repo
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# update the package manager with the new repos
sudo apt-get update

# upgrade the distro
sudo apt-get upgrade -y
sudo apt-get autoremove -y

# install docker
sudo apt-get install -y docker-ce containerd.io

# (optional) install kubectl
sudo apt-get install -y kubectl

# install python3 and docker-compose
sudo apt-get install -y python3.8 python3.8-dev python3.8-venv python3-pip
pip3 install docker-compose

# install java default (currently OpenJDK 11)
sudo apt-get install -y default-jdk

# install git
sudo apt-get install -y git-all

# install maven
sudo apt-get install -y maven

# install tomcat9
sudo apt-get install -y tomcat9 tomcat9-admin tomcat9-common tomcat9-docs tomcat9-examples tomcat9-user
sudo usermod -aG tomcat ${USER}
sudo newgrp tomcat

# create tomcat9 instance and start
cd ~
tomcat9-instance-create scholars
cp /etc/tomcat9/Catalina/localhost/* ~/scholars/conf/Catalina/localhost
~/scholars/bin/startup.sh


# install ssh server
sudo apt-get install -y ssh
sudo /usr/bin/ssh-keygen -A

# create keys for ssh to your WSL account (accept defaults)
ssh-keygen
cd ~/.ssh
cp id_rsa authorized_keys
cd ~


# install solr and init vivocore
cd /opt
wget https://archive.apache.org/dist/lucene/solr/8.6.3/solr-8.6.3.tgz
tar xzf solr-8.6.3.tgz solr-8.6.3/bin/install_solr_service.sh --strip-components=2
sudo bash ./install_solr_service.sh solr-8.6.3.tgz
sudo service solr stop
sudo service solr start
sudo service solr status
sudo su - solr -c "/opt/solr/bin/solr create -c vivocore -n data_driven_schema_configs"
sudo usermod -aG solr ${USER}
sudo newgrp solr

# get vivocore solr files from git and installls 
mkdir repos
cd repos
git clone https://github.com/vivo-project/vivo-solr.git
sudo service solr stop
sudo rm -rv /var/solr/data/vivocore
sudo cp -r ~/repos/vivo-solr/vivocore /var/solr/data/vivocore
sudo chown -R solr vivocore
cd ..

# clone VIVO repos
cd repos
git clone https://github.com/vivo-project/VIVO.git
git clone https://github.com/vivo-project/Vitro.git
git clone https://github.com/vivo-project/VIVO-languages.git
git clone https://github.com/vivo-project/Vitro-languages.git
git clone https://github.com/vivo-project/sample-data.git
cd ..

##########################################################################
# make VIVO-Dir
cd ~
mkdir VIVO

##########################################################################
#For creating a localhost fake smtp
#https://github.com/rnwood/smtp4dev
#http://localhost:3000 is the web interface
#https://hub.docker.com/r/rnwood/smtp4dev
docker run -p 3000:80 -p 25:25 rnwood/smtp4dev:v3

##########################################################################
#MariaDB 10.5 on your Ubuntu
sudo apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
sudo add-apt-repository 'deb [arch=amd64] http://nyc2.mirrors.digitalocean.com/mariadb/repo/10.5/ubuntu bionic main'
sudo apt-get update
sudo apt-get install -y mariadb-server

# start services (tomcat cannot start as a service in WSL - systemd limitation)
sudo service ssh start
sudo service docker start
sudo service solr start
sudo service mariadb start

# adds service starts and updates to profile
echo 'DOTNET_CLI_TELEMETRY_OPTOUT=1' >> .profile
echo 'sudo service ssh start' >> .profile
echo 'sudo service docker start' >> .profile
echo 'docker run -d -p 3000:80 -p 25:25 rnwood/smtp4dev:v3' >> .profile
echo 'sudo service solr start' >> .profile
echo 'sudo service mariadb start' >> .profile
echo '~/scholars/bin/startup.sh' >> .profile
echo 'sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get autoremove -y' >> .profile

cd ~
