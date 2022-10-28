#!/usr/bin/env bash
set -e

## Basic deps
DEBIAN_FRONTEND=noninteractive apt-get install -y curl wget

## source <(curl -s https://imp-bootstrap:sHEG3NTC6og8pCJDTF6EPYb8jLmbskx5Ns@git.nixc.us/colin_/bootstrap-scripts/raw/branch/main/strap.sh) defaults-bootstrap
# curl -sL https://sentry.io/get-cli/ | bash
# echo 'export SENTRY_DSN=https://4d089076433c4a7aa31bbb2741f053fe@sentry.aenow.com/3'
# eval "$(sentry-cli bash-hook)"
curl -o /usr/local/sbin/zsh-setup https://imp-bootstrap:sHEG3NTC6og8pCJDTF6EPYb8jLmbskx5Ns@git.nixc.us/colin_/bootstrap-scripts/raw/branch/main/scripts/zsh-setup.sh && chmod +x /usr/local/sbin/zsh-setup
curl -o /usr/local/sbin/bootstrap https://imp-bootstrap:sHEG3NTC6og8pCJDTF6EPYb8jLmbskx5Ns@git.nixc.us/colin_/bootstrap-scripts/raw/branch/main/scripts/bootstrap.sh && chmod +x /usr/local/sbin/bootstrap
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGLT6xx+pXQl6UfiVe0VTZkC45E/2YE/zfNrWb7mLMtI computer@dewitt.improvingmipractices.com" > /root/.ssh/authorized_keys

## Run bootstrap
case $1 in
  bootstrap )
    /usr/local/sbin/bootstrap $2 $3 $4
  ;;
  defaults-bootstrap )
    /usr/local/sbin/bootstrap none nogluster nosalt  
  ;;
  * )
    /usr/local/sbin/bootstrap none nogluster nosalt
  ;;
esac
