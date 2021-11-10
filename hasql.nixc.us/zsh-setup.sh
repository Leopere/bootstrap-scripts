#!/usr/bin/env bash
## Setup ZSH and ohmyzsh theme
# cd /root/
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
# echo y|sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# chsh -s $(which zsh)
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="pygmalion"/' /root/.zshrc
# echo 'export PUBLIC_IPV4=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/ipv4/address)' >> /root/.zshrc
# echo 'export PUBLIC_IPV6=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/ipv6/address)' >> /root/.zshrc

# ## Install Plugins
#   ## Auto Suggestions
#   git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
#   ## Syntax Highlighting
#   git clone https://github.com/zsh-users/zsh-syntax-highlighting.git
#   # echo "source ${(q-)PWD}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc
#   ## History Substring search.
#   git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search

## Enable plugins
# sed -i 's\plugins=(git)\plugins=(git cp colored-man-pages docker docker-compose extract iterm2 python rsync safe-paste transfer ubuntu zsh_reload zsh-navigation-tools)\' /root/.zshrc


## Cleanup
sed -i 's\bash /root/zsh-setup.sh\\' /root/.profile
rm -f /root/zsh-setup.sh
echo "Relog into terminal finished bootstrapping server"
