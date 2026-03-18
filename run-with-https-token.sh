#!/bin/bash
set -e

# Option 3: Use HTTPS + token authentication via git insteadOf.
#
# This rewrites SSH git URLs to HTTPS with an embedded token, bypassing
# SSH entirely. This is the same approach used by GitHub Actions, GitLab CI,
# and the Qlty runner.
#
# Prerequisites:
#   - GITHUB_TOKEN environment variable set to a PAT or OAuth token with
#     repo access to the source repository
#
# In CI, this token is typically available automatically:
#   - GitHub Actions: ${{ secrets.GITHUB_TOKEN }} or a PAT
#   - Buildkite: set via environment hook or pipeline secret
#   - GitLab CI: $CI_JOB_TOKEN (for GitLab-hosted repos)

if [ -z "$GITHUB_TOKEN" ]; then
  if command -v gh &> /dev/null; then
    GITHUB_TOKEN="$(gh auth token)"
  else
    echo "Error: GITHUB_TOKEN is not set and gh CLI is not available."
    exit 1
  fi
fi

docker build -t docker-source-repro .

docker run --rm \
  -e GITHUB_TOKEN="$GITHUB_TOKEN" \
  --entrypoint /app/entrypoint-with-token.sh \
  docker-source-repro
