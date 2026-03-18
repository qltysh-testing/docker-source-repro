# Qlty Source Fetching Inside Docker

This repository demonstrates how to run `qlty sources fetch` inside a Docker container when your `qlty.toml` references a private Git source.

## The Problem

When running inside Docker, SSH-based source fetching can fail because the container lacks:

- An SSH agent (`SSH_AUTH_SOCK` is not available)
- SSH keys in the default `~/.ssh/` location
- GitHub's host key in `~/.ssh/known_hosts`

These are general SSH-in-Docker issues that affect any tool making SSH connections, not just Qlty.

## Setup

Before testing, edit `.qlty/qlty.toml` and replace the source with your own private repository:

```toml
[[source]]
name = "my-source"
repository = "git@github.com:your-org/your-private-source.git"
branch = "main"
```

The repository must contain a `source.toml` file with valid Qlty source configuration. The credentials you provide (via the options below) must have read access to this repository.

The Dockerfile adds GitHub's host key via `ssh-keyscan` to solve the `known_hosts` issue. The three scripts below show different ways to provide authentication credentials.

## Option 1: Mount SSH Agent Socket

```bash
./run-with-ssh-agent.sh
```

Forwards your host's SSH agent into the container. Qlty authenticates using whichever keys are loaded in your agent.

**Best for:** Local development.

**Not suitable for:** CI environments where Docker containers don't have access to the host's SSH agent.

## Option 2: Mount SSH Key File

```bash
./run-with-ssh-key.sh /path/to/private-key
```

Mounts an unencrypted SSH private key into the container at `~/.ssh/id_ed25519` where libssh2 will find it.

**Requirements:**
- The key must have **no passphrase** (there is no agent or terminal to unlock it)
- The key must have access to the source repository (e.g., as a GitHub deploy key or on a machine user account)
- For SSO-enabled GitHub organizations, the key must be [authorized for SSO](https://docs.github.com/en/authentication/authenticating-with-saml-single-sign-on/authorizing-an-ssh-key-for-use-with-saml-single-sign-on)

To generate a suitable key:

```bash
ssh-keygen -t ed25519 -f /path/to/key -N ""
```

**Best for:** CI environments where an SSH key is stored as a secret (e.g., Buildkite, CircleCI).

**Note:** Requires a Qlty CLI version that includes [qltysh/qlty#2734](https://github.com/qltysh/qlty/pull/2734). Earlier versions have a bug where the libgit2 credential callback recreates the authenticator on every invocation, resetting its state so it retries SSH agent auth indefinitely and never advances to key-file auth.

## Option 3: HTTPS + Token via git insteadOf (Recommended for CI)

```bash
GITHUB_TOKEN=ghp_... ./run-with-https-token.sh
```

Rewrites SSH URLs to HTTPS with an embedded token using `git config url.*.insteadOf`. No SSH is involved at all.

This is the same approach used by:
- [GitHub Actions](https://github.com/actions/checkout) (`actions/checkout`)
- [GitLab CI](https://docs.gitlab.com/ci/jobs/ci_job_token/) (`CI_JOB_TOKEN`)
- The Qlty runner

The script runs these git config commands inside the container before invoking qlty:

```bash
git config --global url."https://oauth2:${GITHUB_TOKEN}@github.com/".insteadOf "git@github.com:"
git config --global --add url."https://oauth2:${GITHUB_TOKEN}@github.com/".insteadOf "https://github.com/"
```

Note the `--add` flag on the second command — both rules share the same config section, so without `--add` the second overwrites the first.

**Best for:** Any CI environment where a GitHub token (PAT, OAuth, or app installation token) is available.

**Works with:** All versions of the Qlty CLI.
