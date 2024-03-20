#!/bin/bash
set -e

# Sentry setup
echo 'export SENTRY_DSN=https://4d089076433c4a7aa31bbb2741f053fe@sentry.aenow.com/3' >> ~/.zshrc
eval "$(sentry-cli bash-hook)"

# Functions for provider-specific configurations
digitalocean() {
  export HOSTNAME=$(curl -s http://169.254.169.254/metadata/v1/hostname)
  hostnamectl set-hostname "$HOSTNAME"
  export PUBLIC_IPV4=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/ipv4/address)
  export PUBLIC_IPV6=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/ipv6/address)
}

ovh() {
  echo "Nothing special for OVH at this stage."
}

# Provider setup
case $1 in
  digitalocean) digitalocean ;;
  ovh) ovh ;;
  none) echo "Nothing special going to be done here." ;;
  *) echo "bootstrap options are:"
     echo "bootstrap ovh [salt/nosalt]"
     echo "bootstrap digitalocean [salt/nosalt]"
     echo "bootstrap none [salt/nosalt]" ;;
esac

# Salt installation
install_salt() {
  sudo curl -fsSL -o /usr/share/keyrings/salt-archive-keyring.gpg https://repo.saltproject.io/salt/py3/ubuntu/22.04/amd64/latest/salt-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/salt-archive-keyring.gpg arch=amd64] https://repo.saltproject.io/salt/py3/ubuntu/22.04/amd64/latest jammy main" | sudo tee /etc/apt/sources.list.d/salt.list
  mkdir -p /etc/salt/minion.d/
  echo 'master: aerence.aenow.fun' > /etc/salt/minion.d/99-master-address.conf
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y salt-minion
}

# Salt installation based on user selection
case $2 in
  salt) install_salt ;;
  nosalt) echo "Not installing salt." ;;
  *) echo "No salt instructions received."
     echo "Options are:"
     echo "bootstrap [hostingProvider] salt"
     echo "bootstrap [hostingProvider] nosalt" ;;
esac

# Apt package installations
echo "Installing Apt Packages"
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::='--force-confold' --force-yes -fuy dist-upgrade
DEBIAN_FRONTEND=noninteractive apt-get install -y asciinema ca-certificates gnupg git glances htop iftop zsh
apt-get update

# Docker and docker-compose installation
echo "Install docker-compose and docker via convenience scripts"
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
DEBIAN_FRONTEND=noninteractive apt-get install -y docker-compose-plugin

# CTOP installation
echo "Installing CTOP"
wget https://github.com/bcicen/ctop/releases/download/v0.7.7/ctop-0.7.7-linux-amd64 -O /usr/local/bin/ctop
chmod +x /usr/local/bin/ctop

# Setup Oh My Zsh on first login
curl -o /root/zsh-setup.sh https://bootstrap:sHEG3NTC6og8pCJDTF6EPYb8jLmbskx5Ns@git.nixc.us/colin/bootstrap-scripts/raw/branch/main/scripts/zsh-setup.sh
echo "zsh-setup" >> ~/.profile
source ~/.profile
