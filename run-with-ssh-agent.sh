#!/bin/bash
set -e

# Option 1: Mount the host's SSH agent socket into the container.
#
# This forwards your local SSH agent into Docker so qlty can authenticate
# using keys already loaded in your agent. Works well for local development
# but is typically not available in CI environments.
#
# Prerequisites:
#   - SSH agent running on the host with a key that has access to the source repo
#   - SSH_AUTH_SOCK environment variable set

if [ -z "$SSH_AUTH_SOCK" ]; then
  echo "Error: SSH_AUTH_SOCK is not set. Start your SSH agent first."
  exit 1
fi

docker build -t docker-source-repro .

docker run --rm \
  -v "$SSH_AUTH_SOCK:/ssh-agent" \
  -e SSH_AUTH_SOCK=/ssh-agent \
  docker-source-repro
