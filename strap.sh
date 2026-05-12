#!/usr/bin/env bash
set -euo pipefail

: "${STRAP_BASE_URL:=https://raw.githubusercontent.com/Leopere/bootstrap-scripts/main}"
: "${STRAP_AUTHORIZED_KEYS:=ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICxoakgL0Tq4mAv+UMnFc3PZptPCXz8ObCsyVmBtiB2P defaultkey_key}"

usage() {
  cat <<USAGE
Usage:
  strap.sh                          run defaults (provider=none, no salt)
  strap.sh defaults-bootstrap       run defaults explicitly
  strap.sh bootstrap PROVIDER SALT  PROVIDER in {none, ovh, digitalocean}; SALT in {salt, nosalt}

Environment overrides:
  STRAP_BASE_URL          base URL for fetching scripts
  STRAP_AUTHORIZED_KEYS   ssh public key(s) to install (default: built-in defaultkey)
USAGE
}

if [ "${EUID:-$(id -u)}" -ne 0 ]; then
  echo "strap.sh must be run as root" >&2
  exit 1
fi

if ! command -v apt-get >/dev/null 2>&1; then
  echo "strap.sh requires a Debian/Ubuntu host (apt-get not found)" >&2
  exit 1
fi

DEBIAN_FRONTEND=noninteractive apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends curl wget ca-certificates

curl -fsSL -o /usr/local/sbin/zsh-setup "$STRAP_BASE_URL/scripts/zsh-setup.sh"
curl -fsSL -o /usr/local/sbin/bootstrap "$STRAP_BASE_URL/scripts/bootstrap.sh"
chmod +x /usr/local/sbin/zsh-setup /usr/local/sbin/bootstrap

mkdir -p /root/.ssh
chmod 700 /root/.ssh
touch /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
grep -qxF "$STRAP_AUTHORIZED_KEYS" /root/.ssh/authorized_keys \
  || echo "$STRAP_AUTHORIZED_KEYS" >> /root/.ssh/authorized_keys

case "${1:-defaults-bootstrap}" in
  bootstrap)
    /usr/local/sbin/bootstrap "${2:-none}" "${3:-nosalt}"
    ;;
  defaults-bootstrap)
    /usr/local/sbin/bootstrap none nosalt
    ;;
  -h|--help|help)
    usage
    ;;
  *)
    echo "Unknown command: ${1:-}" >&2
    usage >&2
    exit 1
    ;;
esac
