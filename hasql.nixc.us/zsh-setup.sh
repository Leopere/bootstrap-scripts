#!/usr/bin/env bash
## Setup ZSH and ohmyzsh theme
# cd /root/
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
# echo y|sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
chsh -s $(which zsh)
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="pygmalion"/g' /root/.zshrc
sed -i 's\bash /root/zsh-setup.sh\\' /root/.profile
rm -f /root/zsh-setup.sh
echo "Relog into terminal finished bootstrapping server"
exit
