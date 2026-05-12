## Bootstrap Script Documentation

### Scope
A server bootstrap script that installs essential utilities and configurations: ZSH (with Oh My Zsh and plugins), Docker (with the Compose v2 plugin), system tooling (htop, glances, iftop, ctop), and optional provider / Salt configuration. Targets Debian/Ubuntu hosts (`apt-get`) on `amd64` or `arm64`. Re-runs are safe — edits to `.zshrc` and SSH keys are idempotent.

### Usage
To run the bootstrap with the default configuration on a fresh host (as root):

```bash
source <(curl -fsSL https://git.nixc.us/colin/bootstrap-scripts/raw/branch/main/strap.sh) defaults-bootstrap
```

This fetches and executes the bootstrap script, applying a standard suite of tools and settings.

### Advanced Usage and Provider-specific Deploys

The bootstrap supports per-provider configuration and selective feature toggles via positional args.

#### Example for OVH deployment

```bash
source <(curl -fsSL https://git.nixc.us/colin/bootstrap-scripts/raw/branch/main/strap.sh) bootstrap ovh nosalt
```

#### Argument reference
- `strap.sh defaults-bootstrap` — provider=`none`, salt=`nosalt`. Also the default when no args are given.
- `strap.sh bootstrap PROVIDER SALT` where:
  - `PROVIDER` ∈ {`none`, `ovh`, `digitalocean`}
  - `SALT` ∈ {`salt`, `nosalt`}

### Environment overrides

| Variable | Default | Purpose |
| --- | --- | --- |
| `STRAP_BASE_URL` | `https://git.nixc.us/colin/bootstrap-scripts/raw/branch/main` | Base URL for fetching `bootstrap.sh` / `zsh-setup.sh` |
| `STRAP_AUTHORIZED_KEYS` | built-in `defaultkey_key` | SSH public key appended to `/root/.ssh/authorized_keys` |
| `STRAP_SENTRY_DSN` | `https://...@sentry.aenow.com/3` | Sentry DSN exported in `.zshrc` |
| `STRAP_SALT_MASTER` | `aerence.aenow.fun` | Salt master address (only used when `SALT=salt`) |

Example:

```bash
STRAP_AUTHORIZED_KEYS="$(cat ~/.ssh/id_ed25519.pub)" \
  source <(curl -fsSL https://git.nixc.us/colin/bootstrap-scripts/raw/branch/main/strap.sh) defaults-bootstrap
```
