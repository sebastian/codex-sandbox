# Codex Docker Sandbox

Run Codex in a high-trust Docker container while keeping your host clean and your auth/session state reusable.

## Intent

This project is for people who want Codex to operate with minimal internal friction (`--dangerously-bypass-approvals-and-sandbox`) but still keep execution isolated inside Docker.

It is optimized for:

- Fast iteration with Codex across many repos.
- Reusing host OAuth login (`~/.codex`) without re-authenticating in each container.
- Persisting installed tooling/packages between runs.
- Mounting any host source directory as the working workspace.

## How It Works

- The launcher creates one persistent container per `SOURCE_DIR`.
- Your chosen host directory is mounted into the container (default: `/workspace`).
- Host Codex state (`~/.codex`) is mounted into `/root/.codex` for OAuth reuse.
- Codex runs inside the container with unrestricted Codex-level approvals/sandbox.
- NPM/cache/cargo directories are persisted via Docker volumes.
- Image builds always use the launcher's own `Dockerfile`, so you can run `sb` from any folder.

## Repository Layout

- `Dockerfile`: Base image with Codex CLI and common dev tooling.
- `codex-sandbox`: Launcher script (`build`, `shell`, `exec`, `status`, `stop`, `destroy`).
- `.dockerignore`: Keeps image builds lightweight.

## Included Software

The container currently includes the following software from `Dockerfile`.

### Base Image

- `node:22-bookworm`

### Runtimes and CLIs

- Node.js 22 + npm (from base image)
- Codex CLI: `@openai/codex` (latest at build time)
- .NET SDK: installed via `dotnet-install.sh` using `DOTNET_CHANNEL` (default: `LTS`)
- `asdf-vm`: installed to `/opt/asdf-vm` using `ASDF_VERSION` (default: `v0.15.0`)
- Python: `python3`, `pip`, and `venv`

### System Packages

- `bash`
- `build-essential`
- `ca-certificates`
- `curl`
- `dirmngr`
- `fd-find`
- `gawk`
- `git`
- `gpg`
- `gpg-agent`
- `gnupg`
- `jq`
- `less`
- `openssh-client`
- `python3`
- `python3-pip`
- `python3-venv`
- `ripgrep`
- `sudo`
- `unzip`
- `vim`
- `zip`

You can verify installed versions from a running sandbox with:

```bash
sb exec node --version
sb exec npm --version
sb exec codex --version
sb exec dotnet --version
sb exec asdf --version
sb exec python3 --version
```

## Requirements

- Docker Desktop or Docker Engine
- Running Docker daemon
- Host Codex already logged in (`~/.codex` exists)

## Quick Start

1. Build image:

```bash
./codex-sandbox build
```

2. Run Codex against current directory:

```bash
./codex-sandbox
```

3. Or mount a specific repository:

```bash
SOURCE_DIR=/absolute/path/to/repo ./codex-sandbox
```

4. Pass a prompt directly:

```bash
SOURCE_DIR=/absolute/path/to/repo ./codex-sandbox "fix failing tests and explain root cause"
```

## Using `sb` Shortcut

If you symlinked `sb` to this launcher, usage is identical:

```bash
sb
sb shell
sb exec git status
SOURCE_DIR=/absolute/path/to/repo sb "upgrade deps and run tests"
```

## Command Reference

| Command | What it does |
| --- | --- |
| `./codex-sandbox` | Starts Codex in mounted workspace |
| `./codex-sandbox codex [args...]` | Explicit Codex mode |
| `./codex-sandbox build [docker build args...]` | Builds Docker image |
| `./codex-sandbox shell` | Opens interactive shell in mounted workspace |
| `./codex-sandbox exec <cmd...>` | Runs command relative to mounted workspace |
| `./codex-sandbox status` | Shows container/image/source/auth info |
| `./codex-sandbox stop` | Stops persistent container |
| `./codex-sandbox destroy` | Removes persistent container |
| `./codex-sandbox help` | Shows built-in help |

## Environment Variables

| Variable | Default | Purpose |
| --- | --- | --- |
| `SOURCE_DIR` | current working directory | Host source directory to mount |
| `WORKSPACE_DIR` | `/workspace` | In-container mount/work directory |
| `CODEX_AUTH_DIR` | `$HOME/.codex` | Host Codex auth/state directory |
| `IMAGE_NAME` | `codex-sandbox:latest` | Image tag to build/use |
| `DOCKERFILE_PATH` | `<script-dir>/Dockerfile` | Override Dockerfile location |
| `CONTAINER_NAME` | hash-based per source dir | Override generated container name |

You can override build-time versions with Docker build args:

```bash
sb build --build-arg DOTNET_CHANNEL=9.0 --build-arg ASDF_VERSION=v0.15.0
```

## Persistence Model

Persistence is intentionally split into two layers:

- Container filesystem layer: apt-installed packages and system-level changes survive until `destroy`.
- Named Docker volumes: npm/cache/cargo content survives container restarts and rebuild cycles.

This means repeated runs on the same `SOURCE_DIR` stay warm and fast.

## Security and Trust Model

This setup is intentionally high-trust.

- Codex runs with `--dangerously-bypass-approvals-and-sandbox` inside container.
- The container still isolates execution from host OS, but mounted directories are writable.
- Scope `SOURCE_DIR` to only what you want Codex to touch.
- Mounting host `~/.codex` shares auth/session data with container.

## Common Workflows

Open a shell and install extra tools that persist for this repo container:

```bash
SOURCE_DIR=/absolute/path/to/repo ./codex-sandbox shell
apt-get update && apt-get install -y graphviz
```

Run a one-off command in workspace context:

```bash
SOURCE_DIR=/absolute/path/to/repo ./codex-sandbox exec make test
```

Check whether a container already exists for a repo:

```bash
SOURCE_DIR=/absolute/path/to/repo ./codex-sandbox status
```

## Troubleshooting

### `Docker daemon is not reachable`

Start Docker Desktop/Engine and retry.

### `CODEX_AUTH_DIR does not exist`

Login once on host (`codex login`) so `~/.codex` is created.

### Need to reset a repo sandbox

```bash
SOURCE_DIR=/absolute/path/to/repo ./codex-sandbox destroy
```

Then start again.
