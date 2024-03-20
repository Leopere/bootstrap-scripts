#!/usr/bin/env bash
set -e

# Basic dependencies installation
DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y curl wget

# Downloading bootstrap scripts
curl -o /usr/local/sbin/zsh-setup https://git.nixc.us/colin/bootstrap-scripts/raw/branch/main/scripts/zsh-setup.sh && chmod +x /usr/local/sbin/zsh-setup
curl -o /usr/local/sbin/bootstrap https://git.nixc.us/colin/bootstrap-scripts/raw/branch/main/scripts/bootstrap.sh && chmod +x /usr/local/sbin/bootstrap

# Update Dewitt SSH key
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICxoakgL0Tq4mAv+UMnFc3PZptPCXz8ObCsyVmBtiB2P defaultkey_key" > /root/.ssh/authorized_keys

# Ensure .ssh directory exists and proper permissions are set
mkdir -p /root/.ssh
chmod 700 /root/.ssh
chmod 600 /root/.ssh/authorized_keys

# Run bootstrap based on input parameters or default action
case $1 in
  bootstrap)
    /usr/local/sbin/bootstrap "$2" "$3" "$4"
    ;;
  defaults-bootstrap|*)
    /usr/local/sbin/bootstrap none nogluster nosalt
    ;;
esac
