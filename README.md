## Bootstrap Script Documentation

### Scope
This document details the usage of a server bootstrap script aimed at installing essential utilities and configurations for server setups. It supports the installation of ZSH, Docker, along with various optimizations and support tools.

### Usage
To initiate the bootstrap process with the default configuration, embed the following command in your server's post-installation scripts:

```bash
#!/usr/bin/env bash
## source <(curl -s https://git.nixc.us/colin/bootstrap-scripts/raw/branch/main/strap.sh) defaults-bootstrap
```

This line fetches and executes the bootstrap script, setting up the server with a standard suite of tools and settings.

### Advanced Usage and Provider Specific Deploys

The bootstrap script accommodates deployments specific to different providers, allowing for the inclusion or exclusion of selected features based on requirements.

#### Example for OVH Deployment:
For deploying on an OVH server with tailored settings, use the example below:

```bash
#!/usr/bin/env bash
source <(curl -s https://git.nixc.us/colin/bootstrap-scripts/raw/branch/main/strap.sh) bootstrap ovh nosalt
```

This example demonstrates how to configure a server specifically for OVH, omitting Salt configuration management.

#### Deployment Customization:
- The first argument after `bootstrap` indicates the target cloud provider or environment (e.g., `ovh`, `digitalocean`).
- The second argument allows for specifying configuration preferences, such as excluding Salt stack installation (`nosalt`).

Adjust these parameters to customize the bootstrap process according to your deployment environment and preferences.