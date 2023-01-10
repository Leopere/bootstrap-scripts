#!/bin/bash
set -e
echo 'export SENTRY_DSN=https://4d089076433c4a7aa31bbb2741f053fe@sentry.aenow.com/3'
eval "$(sentry-cli bash-hook)"
## DigitalOcean's API for obtaining server metadata.
function digitalocean() {
  export HOSTNAME=$(curl -s http://169.254.169.254/metadata/v1/hostname)
  hostnamectl set-hostname $HOSTNAME
  # echo $HOSTNAME > /etc/hostname
  # hostname -F /etc/hostname
  # hostname -f
  export PUBLIC_IPV4=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/ipv4/address)
  export PUBLIC_IPV6=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/ipv6/address)
}
## Add anything for OVH here.
function ovh() {
  echo Nothing special for DigitalOcean at this stage.
}
## Choose which DC provider sepecifics need installed.
case $1 in
  digitalocean )
    digitalocean
  ;;
  ovh )
    ovh
  ;;
  none )
    echo Nothing special going to be done here.
  ;;
  * )
    echo bootstrap options are:
    echo bootstrap ovh [gluster/nogluster] [salt/nosalt]
    echo bootstrap digitalocean [gluster/nogluster] [salt/nosalt]
    echo bootstrap none [gluster/nogluster] [salt/nosalt]
  ;;
esac
function install_salt() {
  # ## Installing Salt for Ubuntu 20.04
  # curl -fsSL -o /usr/share/keyrings/salt-archive-keyring.gpg https://repo.saltproject.io/py3/ubuntu/20.04/amd64/latest/salt-archive-keyring.gpg
  # echo "deb [signed-by=/usr/share/keyrings/salt-archive-keyring.gpg arch=amd64] https://repo.saltproject.io/py3/ubuntu/20.04/amd64/latest focal main" | sudo tee /etc/apt/sources.list.d/salt.list
  sudo curl -fsSL -o /usr/share/keyrings/salt-archive-keyring.gpg https://repo.saltproject.io/salt/py3/ubuntu/22.04/amd64/latest/salt-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/salt-archive-keyring.gpg arch=amd64] https://repo.saltproject.io/salt/py3/ubuntu/22.04/amd64/latest jammy main" | sudo tee /etc/apt/sources.list.d/salt.list
  mkdir -p /etc/salt/minion.d/
  echo 'master: rios.aenow.fun' > /etc/salt/minion.d/99-master-address.conf
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y salt-minion
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
case $2 in
  gluster )
    install_gluster_pre
  ;;
  nogluster )
    echo not installing gluster.
  ;;
  * )
    echo no gluster instructions received.
    echo options are:
    echo bootstrap [hostingProvider] gluster [salt/nosalt]
    echo bootstrap [hostingProvider] nogluster [salt/nosalt]
  ;;
esac
## Installing packages
echo Installing Apt Packages
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::='--force-confold' --force-yes -fuy dist-upgrade
DEBIAN_FRONTEND=noninteractive apt-get install -y asciinema ca-certificates gnupg docker-ctop git glances htop iftop zsh
echo y | curl -sSL https://pkgs.wiretrustee.com/debian/public.key | sudo gpg --dearmor --output /usr/share/keyrings/wiretrustee-archive-keyring.gpg
echo 'deb [signed-by=/usr/share/keyrings/wiretrustee-archive-keyring.gpg] https://pkgs.wiretrustee.com/debian stable main' | sudo tee /etc/apt/sources.list.d/wiretrustee.list
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y netbird

## Install Gluster Post
echo Gluster Post Function
case $2 in
  gluster )
    install_gluster_post
  ;;
  nogluster )
    echo not installing gluster.
  ;;
esac
## Install salt
echo Installing Salt
case $3 in
  salt )
    install_salt

  ;;
  nosalt )
    echo Not installing salt.
  ;;
  * )
    echo no salt instructions received.
    echo options are:
    echo bootstrap [hostingProvider] [gluster/nogluster] salt
    echo bootstrap [hostingProvider] [gluster/nogluster] nosalt
  ;;
esac
## Install docker-compose and docker using convenience scripts
echo Install docker-compose and docker via convenience scripts
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
DEBIAN_FRONTEND=noninteractive apt-get install -y docker-compose-plugin
## Install CTOP Container Top https://github.com/bcicen/ctop
wget https://github.com/bcicen/ctop/releases/download/v0.7.7/ctop-0.7.7-linux-amd64 -O /usr/local/bin/ctop
chmod +x /usr/local/bin/ctop

## This may no longer be required going forward, it'll be better to call it on first login instead with args.
  ## Force install ohmyzsh on first login
  # curl -o /root/zsh-setup.sh https://bootstrap:sHEG3NTC6og8pCJDTF6EPYb8jLmbskx5Ns@git.nixc.us/colin_/do-userdata/raw/branch/main/scripts/zsh-setup.sh
  # echo zsh-setup >> ~/.profile
  # source ~/.profile
