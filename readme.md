# WSL2 Install for VIVO Development

This project provides scripts to set up a development environment for VIVO in Windows Subsystem for Linux 2 (WSL2). It includes scripts to install WSL2 and to set up the development environment in WSL2.

It is designed to be used the WSL2 on Windows 10 Build 2004 or higher and with the Ubuntu 18.04 Distro.

The PowerShell script is to assist those that currently do not have WSL2 installed. You should reboot after running.

## Installation

1. Open PowerShell in Windows.

2. Run the `install_wsl2.ps1` script. This script will install WSL2 on your system.

    ```powershell
    .\install_wsl2.ps1
    ```

3. Once the WSL2 installation is complete, copy the setup_dev_env_in_wsl2_r2.sh script into your WSL2 home directory.

    ```powershell
    cp setup_dev_env_in_wsl2_r2.sh ~
    ```

4. Run the `setup_dev_env_in_wsl2.sh` script. This script will install the development environment in WSL2.

    ```bash
    cd ~
    bash setup_dev_env_in_wsl2_r2.sh
    ```

What's Installed

The setup_dev_env_in_wsl2_r2.sh script installs the following packages:

- Azure CLI: A command-line tool for managing Azure resources.
- .NET SDK 2.1 and 3.1: Software development kits for building .NET applications.
- ~~Mono Complete: A software platform designed to allow developers to easily create cross-platform applications.~~
- Node.js 14 LTS: A JavaScript runtime built on Chrome's V8 JavaScript engine.
- NPM: The package manager for Node.js.
- PowerShell Core 7: A cross-platform automation and configuration tool/framework.
- Docker CE: A platform for developers and sysadmins to develop, ship, and run applications.
- kubectl: A command-line tool for controlling Kubernetes clusters.
- Python 3.8: A programming language that lets you work quickly and integrate systems more effectively.
- Pip3: A package installer for Python.
- docker-compose (via Pip3): A tool for defining and running multi-container Docker applications.
- Git 2.17 (git-all): A free and open-source distributed version control system.
- OpenJDK 11 (JDK and JRE): An open-source implementation of the Java Platform, Standard Edition.
- Maven 3.6: A software project management and comprehension tool.
- Tomcat 9: An open-source implementation of the Java Servlet, JavaServer Pages, Java Expression Language, and Java WebSocket technologies.
- Solr 8.6.3: An open-source enterprise-search platform from the Apache Lucene project.
- smtp4dev: A dummy SMTP server for Windows, Linux, Mac OS-X, and Docker.
- MariaDB 10.5: A community-developed fork of the MySQL relational database management system.
- OpenBSD SSH Server: A free version of the SSH connectivity tools.

## Repositories Added

The setup_dev_env_in_wsl2.sh script also adds the following repositories to your system's list of apt sources:

- Microsoft Azure Repos: This repository provides packages for Azure CLI and .NET Core SDK.
- Microsoft dotNet Core Repo: This repository provides packages for .NET Core SDK.
- Mono Repo: This repository provides packages for Mono, a software platform designed to allow developers to easily create cross-platform applications.
  - While this repo is still added, Mono is no longer installed.
- NodeJS and NPM Repo from Nodesource: This repository provides packages for Node.js and NPM.
- Microsoft Ubuntu Repo: This repository provides packages for various Microsoft software for Ubuntu.
- Docker Repo: This repository provides packages for Docker CE, a platform for developers and sysadmins to develop, ship, and run applications.
- Google Cloud Kubectl Repo: This repository provides packages for kubectl, a command-line tool for controlling Kubernetes clusters.
- MariaDB Repo: This repository provides packages for MariaDB, a community-developed fork of the MySQL relational database management system.

### Note

By adding the above repositories, `apt-get` is able to keep those items up to date. This means that when you update your system with `apt-get update` and `apt-get upgrade`, these packages will be updated along with the rest of your system.

## What the script does beyond package installs

1. Creates the keys for the SSH Server
2. Creates the key pair for the WSL account
3. Creates a tomcat instance called "scholars"
4. Sets up "vivocore" in Solr
5. Appends to .profile the service starts
6. Appends "sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get autoremove -y" to keep the system updated.
7. Turns off Microsoft dotNet Telemetry for additional privacy
8. Clones from GitHub: VIVO, Vitro, VIVO-Languages, Vitro-Languages, and VIVO Sample Data

``` bash
DOTNET_CLI_TELEMETRY_OPTOUT=1
sudo service ssh start
sudo service docker start
docker run -d -p 3000:80 -p 25:25 rnwood/smtp4dev:v3
sudo service solr start
sudo service mariadb start
~/scholars/bin/startup.sh
sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get autoremove -y
```

## Other

You may want to add this to your /etc/security/limits.conf

``` text
solr    soft    nofile  65000
solr    soft    nproc   65000
solr    hard    nofile  65000
solr    hard    nproc   65000
```

Add to ~/scholars/conf/tomcat-users.xml (and make sure you change that password)

``` xml
#paste inside <tomcat-users> </tomcat-users> tags

<!-- user manager can access only manager section -->
<role rolename="manager-gui" />
<user username="manager" password="notagoodpassword" roles="manager-gui" />

<!-- user admin can access manager and admin section both -->
<role rolename="admin-gui" />
<user username="admin" password="notagoodpassword" roles="manager-gui,admin-gui" />
```

To update the paths in the VIVO settings.xml file within vivo_files

``` bash
sed -i 's/wsl_username/'${USER}'/g' settings.xml
```
