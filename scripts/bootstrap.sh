#!/usr/bin/env bash
set -euo pipefail

: "${STRAP_SENTRY_DSN:=https://4d089076433c4a7aa31bbb2741f053fe@sentry.aenow.com/3}"
: "${STRAP_SALT_MASTER:=aerence.aenow.fun}"

PROVIDER="${1:-none}"
SALT_MODE="${2:-nosalt}"

# shellcheck disable=SC1091
. /etc/os-release
CODENAME="${UBUNTU_CODENAME:-${VERSION_CODENAME:-jammy}}"
VERSION_ID_SHORT="${VERSION_ID:-22.04}"
ARCH="$(dpkg --print-architecture)"
HOME_DIR="${HOME:-/root}"
ZSHRC="$HOME_DIR/.zshrc"

append_unique() {
  local line="$1" file="$2"
  touch "$file"
  grep -qxF "$line" "$file" || echo "$line" >> "$file"
}

append_unique "export SENTRY_DSN=$STRAP_SENTRY_DSN" "$ZSHRC"

digitalocean() {
  local md_base=http://169.254.169.254/metadata/v1
  local hostname
  hostname=$(curl -fsS "$md_base/hostname" || true)
  if [ -n "$hostname" ]; then
    hostnamectl set-hostname "$hostname"
  fi
}

ovh() {
  echo "No OVH-specific configuration needed."
}

case "$PROVIDER" in
  digitalocean) digitalocean ;;
  ovh)          ovh ;;
  none)         echo "No provider-specific configuration." ;;
  *)
    echo "Unknown provider '$PROVIDER'. Options: none, ovh, digitalocean" >&2
    exit 1
    ;;
esac

install_salt() {
  curl -fsSL -o /usr/share/keyrings/salt-archive-keyring.gpg \
    "https://repo.saltproject.io/salt/py3/ubuntu/${VERSION_ID_SHORT}/${ARCH}/latest/salt-archive-keyring.gpg"
  echo "deb [signed-by=/usr/share/keyrings/salt-archive-keyring.gpg arch=${ARCH}] https://repo.saltproject.io/salt/py3/ubuntu/${VERSION_ID_SHORT}/${ARCH}/latest ${CODENAME} main" \
    > /etc/apt/sources.list.d/salt.list
  mkdir -p /etc/salt/minion.d/
  echo "master: $STRAP_SALT_MASTER" > /etc/salt/minion.d/99-master-address.conf
  DEBIAN_FRONTEND=noninteractive apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends salt-minion
}

case "$SALT_MODE" in
  salt)   install_salt ;;
  nosalt) echo "Skipping salt-minion install." ;;
  *)
    echo "Unknown salt mode '$SALT_MODE'. Options: salt, nosalt" >&2
    exit 1
    ;;
esac

echo "Installing apt packages"
DEBIAN_FRONTEND=noninteractive apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::='--force-confold' -y dist-upgrade
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  asciinema ca-certificates gnupg git glances htop iftop zsh

echo "Installing Docker and compose plugin"
if ! command -v docker >/dev/null 2>&1; then
  curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
  sh /tmp/get-docker.sh
  rm -f /tmp/get-docker.sh
fi
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends docker-compose-plugin

init_swarm() {
  local state advertise_addr err
  state="$(docker info --format '{{.Swarm.LocalNodeState}}' 2>/dev/null || true)"
  if [ "$state" = "active" ]; then
    echo "Swarm already active, skipping init."
    return 0
  fi
  if err="$(docker swarm init 2>&1 >/dev/null)"; then
    echo "Swarm initialized."
    return 0
  fi
  # Multi-interface hosts force --advertise-addr; pick the first global IPv4.
  if echo "$err" | grep -q 'could not choose'; then
    advertise_addr="$(ip -4 -o addr show scope global 2>/dev/null | awk '{print $4}' | cut -d/ -f1 | head -n1)"
    if [ -n "$advertise_addr" ]; then
      echo "Retrying swarm init with --advertise-addr $advertise_addr"
      docker swarm init --advertise-addr "$advertise_addr"
      return 0
    fi
  fi
  echo "$err" >&2
  return 1
}

echo "Initializing single-node Docker Swarm"
init_swarm

echo "Installing CTOP"
case "$ARCH" in
  amd64|arm64)
    curl -fsSL "https://github.com/bcicen/ctop/releases/download/v0.7.7/ctop-0.7.7-linux-${ARCH}" \
      -o /usr/local/bin/ctop
    chmod +x /usr/local/bin/ctop
    ;;
  *)
    echo "Skipping CTOP (unsupported arch: $ARCH)" >&2
    ;;
esac

echo "Running zsh setup"
STRAP_SENTRY_DSN="$STRAP_SENTRY_DSN" /usr/local/sbin/zsh-setup "$PROVIDER" ae-sentry
