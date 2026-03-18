#!/bin/bash
set -e

# Option 2: Mount an SSH private key file into the container.
#
# This mounts an unencrypted SSH key at the default path where qlty (via
# libssh2) looks for keys. The key must not have a passphrase since there
# is no agent or terminal to prompt for one.
#
# Prerequisites:
#   - An unencrypted ed25519 SSH key with access to the source repo
#   - The key must be authorized for any SSO-enabled GitHub organizations
#
# To generate a suitable key:
#   ssh-keygen -t ed25519 -f /path/to/key -N ""
#
# Then add the public key to GitHub (as a deploy key on the repo or as
# an SSH key on a machine user account).

SSH_KEY="${1:-$HOME/.ssh/id_ed25519}"

if [ ! -f "$SSH_KEY" ]; then
  echo "Error: SSH key not found at $SSH_KEY"
  echo "Usage: $0 [path/to/private-key]"
  exit 1
fi

PUB_KEY="${SSH_KEY}.pub"

docker build -t docker-source-repro .

if [ -f "$PUB_KEY" ]; then
  docker run --rm \
    -v "$SSH_KEY:/root/.ssh/id_ed25519:ro" \
    -v "$PUB_KEY:/root/.ssh/id_ed25519.pub:ro" \
    docker-source-repro
else
  docker run --rm \
    -v "$SSH_KEY:/root/.ssh/id_ed25519:ro" \
    docker-source-repro
fi
