#!/usr/bin/env bash
## Setup ZSH and ohmyzsh theme
# cd ~/
USRDIR=$(echo ~)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
# echo y|sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
sed -i'' -e 's@ZSH_THEME="robbyrussell"@ZSH_THEME="pygmalion"@' $USRDIR/.zshrc
## BLOCK THIS OUT IF NOT DEPLOYING TO DIGITALOCEAN ##
echo 'export PUBLIC_IPV4=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/ipv4/address)' >> $USRDIR/.zshrc
echo 'export PUBLIC_IPV6=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/ipv6/address)' >> $USRDIR/.zshrc
echo 'export SENTRY_DSN=https://d7eb76933ae046c9a4fd3d29572b1462:3aba191d95a648118e78cc5f81cbd92c@sentry.adventuresinnewmedia.com/43' >> $USRDIR/.zshrc
## BLOCK THIS OUT IF NOT DEPLOYING TO DIGITALOCEAN ##

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
sed -i'' -e 's@plugins=(git)@plugins=(git cp colored-man-pages docker docker-compose extract iterm2 python rsync safe-paste transfer ubuntu zsh-navigation-tools zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search command-time)@' $USRDIR/.zshrc


## Cleanup
sed -i'' -e 's@bash $USRDIR/zsh-setup.sh@@' $USRDIR/.profile
#rm -f $USRDIR/zsh-setup.sh
echo "Relog into terminal finished bootstrapping server"
chsh -s $(which zsh)
zsh
source $USRDIR/.zshrc
