#!/bin/bash
## digitalocean-user-data sHEG3NTC6og8pCJDTF6EPYb8jLmbskx5Ns
## digitalocean-user-data@nixc.us

export HOSTNAME=$(curl -s http://169.254.169.254/metadata/v1/hostname)
echo $HOSTNAME > /etc/hostname
hostname -F /etc/hostname
hostname -f
export PUBLIC_IPV4=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/ipv4/address)
export PUBLIC_IPV6=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/ipv6/address)
curl -fsSL -o /usr/share/keyrings/salt-archive-keyring.gpg https://repo.saltproject.io/py3/ubuntu/20.04/amd64/latest/salt-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/salt-archive-keyring.gpg arch=amd64] https://repo.saltproject.io/py3/ubuntu/20.04/amd64/latest focal main" | sudo tee /etc/apt/sources.list.d/salt.list
echo |add-apt-repository ppa:gluster/glusterfs-7
apt-get update
apt-get dist-upgrade -y
mkdir -P /etc/salt/minion.d/
echo 'master: nacl.nixc.us' > /etc/salt/minion.d/99-master-address.conf
apt-get install -y iftop htop glances zsh glusterfs-server glusterfs-client salt-minion
cd /root/
#sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
echo y|sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
sed -i 's/ZSH_THEME="robbyrussel"/ZSH_THEME="pygmalion"/g' /root/.zshrc
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
