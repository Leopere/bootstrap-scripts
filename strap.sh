## #!/usr/bin/env bash
set -e
## source <(curl -s https://digitalocean-user-data:sHEG3NTC6og8pCJDTF6EPYb8jLmbskx5Ns@git.nixc.us/Colin_/bootstrap-scripts/raw/branch/main/strap.sh)
curl -sL https://sentry.io/get-cli/ | bash
echo 'export SENTRY_DSN=https://4d089076433c4a7aa31bbb2741f053fe@sentry.aenow.com/3'
eval "$(sentry-cli bash-hook)"
curl -o /usr/local/sbin/zsh-setup https://digitalocean-user-data:sHEG3NTC6og8pCJDTF6EPYb8jLmbskx5Ns@git.nixc.us/Colin_/bootstrap-scripts/raw/branch/main/scripts/zsh-setup.sh && chmod +x /usr/local/sbin/zsh-setup
curl -o /usr/local/sbin/bootstrap https://digitalocean-user-data:sHEG3NTC6og8pCJDTF6EPYb8jLmbskx5Ns@git.nixc.us/Colin_/bootstrap-scripts/raw/branch/main/scripts/bootstrap.sh && chmod +x /usr/local/sbin/bootstrap
