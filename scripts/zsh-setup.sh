#!/usr/bin/env bash
## Setup ZSH and ohmyzsh theme
# cd ~/
USRDIR=$(echo ~)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
# echo y|sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
sed -i'' -e 's@ZSH_THEME="robbyrussell"@ZSH_THEME="pygmalion"@' $USRDIR/.zshrc

## Just install sentry DSN server info here.
function ae_sentry() {
  # https://4d089076433c4a7aa31bbb2741f053fe@sentry.aenow.com/3
  echo 'export SENTRY_DSN=https://4d089076433c4a7aa31bbb2741f053fe@sentry.aenow.com/3' >> $USRDIR/.zshrc
}

## DigitalOcean's API for obtaining server metadata.
function digitalocean() {
  echo 'export PUBLIC_IPV4=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/ipv4/address)' >> $USRDIR/.zshrc
  echo 'export PUBLIC_IPV6=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/ipv6/address)' >> $USRDIR/.zshrc
}

## Add anything for OVH here.
function ovh() {
  echo Nothing to see here at the moment.
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
    echo zsh-setup.sh options are:
    echo zsh-setup.sh ovh
    echo zsh-setup.sh digitalocean
    echo zsh-setup.sh none
  ;;
esac

case $2 in
  ae-sentry )
    ae_sentry
  ;;
  my-sentry )
    echo "buy a server for this you poor old sodd"
  ;;
  none )
    echo You have elected to not add a Sentry server.
  ;;
  * )
    echo No sentry option chosen however one must be chosen.  The options are:
    echo "zsh-setup.sh hosting-provider ae-sentry"
    echo "zsh-setup.sh hosting-provider my-sentry"
    echo "zsh-setup.sh hosting-provider none"
  ;;
esac

## Docker build fast
echo "export DOCKER_BUILDKIT=1 # or configure in daemon.json" >> ~/.zshrc
echo "export COMPOSE_DOCKER_CLI_BUILD=1" >> ~/.zshrc

## Install Plugins
  ## Auto Suggestions
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$USRDIR/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  ## Syntax Highlighting
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$USRDIR/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
  ## History Substring search.
  git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-$USRDIR/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
  ## ZSH Command Execution Time
  git clone https://github.com/popstas/zsh-command-time.git ${ZSH_CUSTOM:-$USRDIR/.oh-my-zsh/custom}/plugins/command-time
  ## Configure plugins and envvars.
  cat <<EOF >> ~/.zshrc
  # If command execution time above min. time, plugins will not output time.
  ZSH_COMMAND_TIME_MIN_SECONDS=3

  # Message to display (set to "" for disable).
  ZSH_COMMAND_TIME_MSG="Execution time: %s"

  # Message color.
  ZSH_COMMAND_TIME_COLOR="cyan"

  # Exclude some commands
  ZSH_COMMAND_TIME_EXCLUDE=(vim mcedit nano ctop ssh)
EOF

## Enable plugins
sed -i'' -e 's@plugins=(git)@plugins=(git cp colored-man-pages docker docker-compose extract iterm2 python rsync safe-paste transfer ubuntu zsh-navigation-tools zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search command-time universalarchive)@' $USRDIR/.zshrc

## Cleanup
sed -i'' -e 's@bash $USRDIR/zsh-setup.sh@@' $USRDIR/.profile
#rm -f $USRDIR/zsh-setup.sh
echo "Relog into terminal finished bootstrapping server"
chsh -s $(which zsh)
zsh
source $USRDIR/.zshrc
