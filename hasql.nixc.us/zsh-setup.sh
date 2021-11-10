#!/usr/bin/env bash
## Setup ZSH and ohmyzsh theme
# cd /root/
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
# echo y|sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="pygmalion"/' /root/.zshrc
echo 'export PUBLIC_IPV4=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/ipv4/address)' >> /root/.zshrc
echo 'export PUBLIC_IPV6=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/ipv6/address)' >> /root/.zshrc
echo 'export SENTRY_DSN=https://d7eb76933ae046c9a4fd3d29572b1462:3aba191d95a648118e78cc5f81cbd92c@sentry.adventuresinnewmedia.com/43' >> /root/.zshrc

## Install Plugins
  ## Auto Suggestions
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  ## Syntax Highlighting
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
  ## History Substring search.
  git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search

## Enable plugins
sed -i 's\plugins=(git)\plugins=(git cp colored-man-pages docker docker-compose extract iterm2 python rsync safe-paste transfer ubuntu zsh-navigation-tools zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search)\' /root/.zshrc


## Cleanup
sed -i 's\bash /root/zsh-setup.sh\\' /root/.profile
rm -f /root/zsh-setup.sh
echo "Relog into terminal finished bootstrapping server"
chsh -s $(which zsh)
zsh
source /root/.zshrc
