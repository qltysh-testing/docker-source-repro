#!/bin/sh
set -e

# Rewrite SSH and HTTPS URLs to use the provided token.
# Must use --add for the second rule since both share the same config key.
git config --global url."https://oauth2:${GITHUB_TOKEN}@github.com/".insteadOf "git@github.com:"
git config --global --add url."https://oauth2:${GITHUB_TOKEN}@github.com/".insteadOf "https://github.com/"

# Run tests
bundle exec rspec --require spec_helper

# Fetch qlty sources
echo "--- Fetching qlty sources ---"
qlty sources fetch

echo "--- Source cache contents ---"
find /root/.qlty/cache/sources -maxdepth 3 -not -path "*/.git/*" -type f
