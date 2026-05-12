#!/usr/bin/env bash
set -euo pipefail

: "${STRAP_SENTRY_DSN:=https://4d089076433c4a7aa31bbb2741f053fe@sentry.aenow.com/3}"

USR_HOME="${HOME:-/root}"
ZSHRC="$USR_HOME/.zshrc"

append_unique() {
  local line="$1" file="$2"
  touch "$file"
  grep -qxF "$line" "$file" || echo "$line" >> "$file"
}

clone_plugin() {
  local repo="$1" dest="$2"
  [ -d "$dest" ] || git clone --depth=1 "$repo" "$dest"
}

usage() {
  echo "Usage: zsh-setup [digitalocean|ovh|none] [ae-sentry|none]" >&2
}

install_omz() {
  if [ ! -d "$USR_HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi
  if [ -f "$ZSHRC" ]; then
    sed -i -e 's@ZSH_THEME="robbyrussell"@ZSH_THEME="pygmalion"@' "$ZSHRC"
  fi
}

ae_sentry() {
  append_unique "export SENTRY_DSN=$STRAP_SENTRY_DSN" "$ZSHRC"
}

digitalocean() {
  # shellcheck disable=SC2016
  append_unique 'export PUBLIC_IPV4=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/ipv4/address)' "$ZSHRC"
  # shellcheck disable=SC2016
  append_unique 'export PUBLIC_IPV6=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/ipv6/address)' "$ZSHRC"
}

ovh() {
  echo "No OVH-specific zsh configuration."
}

configure_plugins() {
  local custom="${ZSH_CUSTOM:-$USR_HOME/.oh-my-zsh/custom}"
  clone_plugin https://github.com/zsh-users/zsh-autosuggestions          "$custom/plugins/zsh-autosuggestions"
  clone_plugin https://github.com/zsh-users/zsh-syntax-highlighting.git  "$custom/plugins/zsh-syntax-highlighting"
  clone_plugin https://github.com/zsh-users/zsh-history-substring-search "$custom/plugins/zsh-history-substring-search"
  clone_plugin https://github.com/popstas/zsh-command-time.git           "$custom/plugins/command-time"

  append_unique 'ZSH_COMMAND_TIME_MIN_SECONDS=3' "$ZSHRC"
  append_unique 'ZSH_COMMAND_TIME_MSG="Execution time: %s"' "$ZSHRC"
  append_unique 'ZSH_COMMAND_TIME_COLOR="cyan"' "$ZSHRC"
  append_unique 'ZSH_COMMAND_TIME_EXCLUDE=(vim mcedit nano ctop ssh)' "$ZSHRC"

  local plugin_line='plugins=(git cp colored-man-pages docker docker-compose extract iterm2 python rsync safe-paste transfer ubuntu zsh-navigation-tools zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search command-time universalarchive)'
  if grep -q '^plugins=(git)$' "$ZSHRC"; then
    sed -i -e "s@^plugins=(git)\$@$plugin_line@" "$ZSHRC"
  elif ! grep -qxF "$plugin_line" "$ZSHRC"; then
    echo "$plugin_line" >> "$ZSHRC"
  fi
}

clean_profile_remnants() {
  if [ -f "$USR_HOME/.profile" ]; then
    sed -i -e '/^zsh-setup$/d' -e '/zsh-setup\.sh/d' "$USR_HOME/.profile"
  fi
}

install_omz

case "${1:-none}" in
  digitalocean) digitalocean ;;
  ovh)          ovh ;;
  none)         ;;
  *)            usage ;;
esac

case "${2:-none}" in
  ae-sentry) ae_sentry ;;
  none)      ;;
  *)         usage ;;
esac

append_unique 'export DOCKER_BUILDKIT=1'          "$ZSHRC"
append_unique 'export COMPOSE_DOCKER_CLI_BUILD=1' "$ZSHRC"

configure_plugins
clean_profile_remnants

ZSH_BIN="$(command -v zsh || true)"
if [ -n "$ZSH_BIN" ]; then
  USER_NAME="$(id -un)"
  CURRENT_SHELL="$(getent passwd "$USER_NAME" | cut -d: -f7 || true)"
  if [ "$CURRENT_SHELL" != "$ZSH_BIN" ]; then
    chsh -s "$ZSH_BIN" "$USER_NAME" || true
  fi
fi

echo "Bootstrap complete. Relog to start zsh."

if [ -n "$ZSH_BIN" ] && [ -t 0 ] && [ -t 1 ]; then
  exec "$ZSH_BIN"
fi
