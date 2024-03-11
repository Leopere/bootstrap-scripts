## Scope
Generic server bootstrap to get some of the most basic utilities installed that would typically be everywhere I deploy these days.  This includes ZSH, Sentry, Gluster, Salt, Docker and support tools and various other optimizations.

## Usage
```bash
#!/usr/bin/env bash
## source <(curl -s https://git.nixc.us/colin/bootstrap-scripts/raw/branch/main/strap.sh) defaults-bootstrap
```
Copy the above into any server post install scripts box and it should get things going pretty quickly.

## Advanced Usage and Provider Specific Deploys

For example if you wanted to deploy to ovh you would use the following example.
```bash
#!/usr/bin/env bash
source <(curl -s https://git.nixc.us/colin/bootstrap-scripts/raw/branch/main/strap.sh) bootstrap ovh gluster nosalt
```
