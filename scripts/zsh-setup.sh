#!/usr/bin/env bash

USRDIR=$(echo ~)

# Simplify installation command
curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh -s -- --unattended

# Update ZSH theme directly
sed -i'' -e 's@ZSH_THEME="robbyrussell"@ZSH_THEME="pygmalion"@' "$USRDIR/.zshrc"

ae_sentry() {
  echo 'export SENTRY_DSN=https://4d089076433c4a7aa31bbb2741f053fe@sentry.aenow.com/3' >> "$USRDIR/.zshrc"
}

digitalocean() {
  echo 'export PUBLIC_IPV4=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/ipv4/address)' >> "$USRDIR/.zshrc"
  echo 'export PUBLIC_IPV6=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/ipv6/address)' >> "$USRDIR/.zshrc"
}

ovh() {
  echo "Nothing to see here at the moment."
}

configure_plugins() {
  # Clone only if directory does not exist to prevent errors on rerun
  [ ! -d "${ZSH_CUSTOM:-$USRDIR/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ] && git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$USRDIR/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
  [ ! -d "${ZSH_CUSTOM:-$USRDIR/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ] && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-$USRDIR/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
  [ ! -d "${ZSH_CUSTOM:-$USRDIR/.oh-my-zsh/custom}/plugins/zsh-history-substring-search" ] && git clone https://github.com/zsh-users/zsh-history-substring-search "${ZSH_CUSTOM:-$USRDIR/.oh-my-zsh/custom}/plugins/zsh-history-substring-search"
  [ ! -d "${ZSH_CUSTOM:-$USRDIR/.oh-my-zsh/custom}/plugins/command-time" ] && git clone https://github.com/popstas/zsh-command-time.git "${ZSH_CUSTOM:-$USRDIR/.oh-my-zsh/custom}/plugins/command-time"
  
  cat <<EOF >> "$USRDIR/.zshrc"
ZSH_COMMAND_TIME_MIN_SECONDS=3
ZSH_COMMAND_TIME_MSG="Execution time: %s"
ZSH_COMMAND_TIME_COLOR="cyan"
ZSH_COMMAND_TIME_EXCLUDE=(vim mcedit nano ctop ssh)
EOF

  sed -i'' -e 's@plugins=(git)@plugins=(git cp colored-man-pages docker docker-compose extract iterm2 python rsync safe-paste transfer ubuntu zsh-navigation-tools zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search command-time universalarchive)@' "$USRDIR/.zshrc"
}

# Process options
case $1 in
  digitalocean) digitalocean ;;
  ovh) ovh ;;
  *) echo "Usage: zsh-setup.sh [digitalocean|ovh|none]" ;;
esac

case $2 in
  ae-sentry) ae_sentry ;;
  none) echo "No Sentry server added." ;;
  *) echo "Usage: zsh-setup.sh hosting-provider [ae-sentry|my-sentry|none]" ;;
esac

echo "export DOCKER_BUILDKIT=1" >> "$USRDIR/.zshrc"
echo "export COMPOSE_DOCKER_CLI_BUILD=1" >> "$USRDIR/.zshrc"

configure_plugins

sed -i'' -e "/bash \$USRDIR\/zsh-setup.sh/d" "$USRDIR/.profile"

# Consider not removing the script automatically for debugging or rerun
# rm -f "$USRDIR/zsh-setup.sh"

echo "Relog into terminal finished bootstrapping server"

chsh -s "$(which zsh)"
zsh
source "$USRDIR/.zshrc"
