#!/usr/bin/env bash
## digitalocean-user-data sHEG3NTC6og8pCJDTF6EPYb8jLmbskx5Ns
## digitalocean-user-data@nixc.us
## source <(curl -s https://digitalocean-user-data:sHEG3NTC6og8pCJDTF6EPYb8jLmbskx5Ns@git.nixc.us/Colin_/do-userdata/raw/branch/master/hasql.nixc.us/user-data.sh)

export HOSTNAME=$(curl -s http://169.254.169.254/metadata/v1/hostname)
echo $HOSTNAME > /etc/hostname
hostname -F /etc/hostname
hostname -f
export PUBLIC_IPV4=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/ipv4/address)
export PUBLIC_IPV6=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/ipv6/address)

## Installing Salt for Ubuntu 20.04
curl -fsSL -o /usr/share/keyrings/salt-archive-keyring.gpg https://repo.saltproject.io/py3/ubuntu/20.04/amd64/latest/salt-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/salt-archive-keyring.gpg arch=amd64] https://repo.saltproject.io/py3/ubuntu/20.04/amd64/latest focal main" | sudo tee /etc/apt/sources.list.d/salt.list
mkdir -P /etc/salt/minion.d/
echo 'master: nacl.nixc.us' > /etc/salt/minion.d/99-master-address.conf

## Installing Glusterfs-7 https://www.digitalocean.com/community/tutorials/how-to-create-a-redundant-storage-pool-using-glusterfs-on-ubuntu-20-04
echo |add-apt-repository ppa:gluster/glusterfs-7

## Installing packages
apt-get update
apt-get dist-upgrade -y
apt-get install -y iftop htop glances zsh glusterfs-server glusterfs-client salt-minion

## Setup ZSH and ohmyzsh theme
cd /root/
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
#echo y|sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
chsh -s /bin/zsh
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="pygmalion"/g' /root/.zshrc

## Install docker-compose and docker using convenience scripts
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
