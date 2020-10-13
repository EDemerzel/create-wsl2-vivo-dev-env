Who is this designed for?
------------------------------------
This script can be used by any dev, but is specifically created for a VIVO dev that may also want or have the need to use that env for other projects.\
It is designed to be used the WSL2 on Windows 10 Build 2004 or higher and with the Ubuntu 18.04 Distro.


Sets up the following within WSL2
------------------------------------
Azure CLI\
dotNet SDK 2.1\
dotNet SDK 3.1\
Mono Complete\
NodeJS 12 LTS\
NPM\
PowerShell Core 7\
Docker CE\
kubectl\
Python 3.8\
Pip3\
docker-compose (via Pip3)\
Git 2.17 (git-all)\
OpenJDK 11 (JDK and JRE)\
Maven 3.6\
Tomcat 9\
Solr 8.6.3\
smtp4dev (as a docker container)\
MariaDB 10.5\
OpenBSD SSH Server

Adds the Repos
-------------------------------------
Microsoft Azure Repos (and Key)\
Microsoft dotNet Core Repo (and Key)\
Mono Repo (and Key)\
NodeJS and NPM Repo from Nodesource\
Microsoft Ubuntu Repo (and Key)\
Docker Repo (and Key)\
Google Cloud Kubectl Repo (and Key)\
MariaDB Repo (and Key)

(Note: By adding the above repos apt-get is able to keep those items up to date.)
