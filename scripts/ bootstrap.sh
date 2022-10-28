#!/usr/bin/env bash
set -e

echo 'export SENTRY_DSN=https://4d089076433c4a7aa31bbb2741f053fe@sentry.aenow.com/3'
eval "$(sentry-cli bash-hook)"

## Determine in the future why these were here. https://docs.digitalocean.com/products/droplets/how-to/provide-user-data/
## digitalocean-user-data sHEG3NTC6og8pCJDTF6EPYb8jLmbskx5Ns
## digitalocean-user-data@nixc.us

# curl -sL https://sentry.io/get-cli/ | bash

## BLOCK THIS OUT IF NOT DEPLOYING TO DIGITALOCEAN ##
export HOSTNAME=$(curl -s http://169.254.169.254/metadata/v1/hostname)
echo $HOSTNAME > /etc/hostname
hostname -F /etc/hostname
hostname -f
export PUBLIC_IPV4=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/ipv4/address)
export PUBLIC_IPV6=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/ipv6/address)
## BLOCK THIS OUT IF NOT DEPLOYING TO DIGITALOCEAN ##

function install_salt() {
  ## Installing Salt for Ubuntu 20.04
  curl -fsSL -o /usr/share/keyrings/salt-archive-keyring.gpg https://repo.saltproject.io/py3/ubuntu/20.04/amd64/latest/salt-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/salt-archive-keyring.gpg arch=amd64] https://repo.saltproject.io/py3/ubuntu/20.04/amd64/latest focal main" | sudo tee /etc/apt/sources.list.d/salt.list
  mkdir -p /etc/salt/minion.d/
  echo 'master: salt.aenow.fun' > /etc/salt/minion.d/99-master-address.conf  
}

function install_gluster_pre() {
  ## Installing Glusterfs-7 https://www.digitalocean.com/community/tutorials/how-to-create-a-redundant-storage-pool-using-glusterfs-on-ubuntu-20-04
  apt-get update && apt-get -y install software-properties-common dirmngr apt-transport-https lsb-release ca-certificates
  echo |add-apt-repository ppa:gluster/glusterfs-7
}
function install_gluster_post() {
  DEBIAN_FRONTEND=noninteractive apt-get install -y glusterfs-server glusterfs-client
}

## Install Container Top ctop
echo "deb http://packages.azlux.fr/debian/ buster main" | sudo tee /etc/apt/sources.list.d/azlux.list
wget -qO - https://azlux.fr/repo.gpg.key | sudo apt-key add -

## Install Gluster Pre
echo Gluster Pre Function
case $1 in
  gluster )
    install_gluster_pre
  ;;
  nogluster )
    echo not installing gluster.
  ;;
  * )
    echo no gluster instructions received.
    echo options are:
    echo ./bootstrap gluster [salt/nosalt]
    echo ./bootstrap nogluster [salt/nosalt]
  ;;
esac

## Installing packages
echo Installing Apt Packages
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::='--force-confold' --force-yes -fuy dist-upgrade
DEBIAN_FRONTEND=noninteractive apt-get install -y asciinema docker-ctop git glances htop iftop salt-minion zsh

## Install Gluster Post
echo Gluster Post Function
case $1 in
  gluster )
    install_gluster_post
  ;;
  nogluster )
    echo not installing gluster.
  ;;
esac

## Install salt
echo Installing Salt
case $2 in
  salt )
    install_salt
  ;;
  nosalt )
    echo Not installing salt.
  ;;
  * )
    echo no salt instructions received.
    echo options are:
    echo ./bootstrap [gluster/nogluster] salt
    echo ./bootstrap [gluster/nogluster] nosalt
  ;;
esac

## Install docker-compose and docker using convenience scripts docker-compose-plugin via apt and container top via wget
echo Install docker-compose and docker via convenience scripts
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
DEBIAN_FRONTEND=noninteractive apt-get install -y docker-compose-plugin
## Install CTOP Container Top https://github.com/bcicen/ctop
wget https://github.com/bcicen/ctop/releases/download/0.7.7/ctop-0.7.7-linux-amd64 -O /usr/local/bin/ctop
chmod +x /usr/local/bin/ctop

## This may no longer be required going forward, it'll be better to call it on first login instead with args.
  ## Force install ohmyzsh on first login
  # curl -o /root/zsh-setup.sh https://digitalocean-user-data:sHEG3NTC6og8pCJDTF6EPYb8jLmbskx5Ns@git.nixc.us/Colin_/do-userdata/raw/branch/main/scripts/zsh-setup.sh
  # echo zsh-setup >> ~/.profile
  # source ~/.profile