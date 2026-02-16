# codex-sandbox

Run Codex in Docker with host OAuth, workspace mounting, and persistent tooling.

## What this gives you

- Reuse host auth: mounts `~/.codex` into the container.
- Work on any repo: mount host directory to `/workspace`.
- Low friction Codex: runs with `--dangerously-bypass-approvals-and-sandbox` inside Docker.
- Persistence: one container per `SOURCE_DIR` so installed tools remain available.

## Quick start

```bash
# build image
sb build

# run Codex against current directory
sb

# run Codex against a specific repo
SOURCE_DIR=/absolute/path/to/repo sb

# open a shell in the mounted workspace
SOURCE_DIR=/absolute/path/to/repo sb shell

# run one command in the mounted workspace
SOURCE_DIR=/absolute/path/to/repo sb exec git status

# install tools from .tool-versions in mounted workspace
SOURCE_DIR=/absolute/path/to/repo sb install-tools
```

## Commands

- `sb` or `sb codex [args...]`
- `sb build [docker build args...]`
- `sb shell`
- `sb exec <command...>`
- `sb install-tools`
- `sb status`
- `sb stop`
- `sb destroy`

## Included software

- Base: `node:current-bookworm`
- Codex CLI: `@openai/codex`
- .NET SDK: installed from `DOTNET_CHANNEL` (default `LTS`)
- `asdf-vm`: installed from `ASDF_VERSION` (default `v0.15.0`)
- Core tools: `git`, `ripgrep`, `python3`, `pip`, `venv`, `build-essential`, `curl`, `jq`, `vim`, `zip`, `unzip`

Check versions:

```bash
sb exec codex --version
sb exec dotnet --version
sb exec asdf --version
sb exec python3 --version
```

## Environment variables

- `SOURCE_DIR` (default: current directory)
- `WORKSPACE_DIR` (default: `/workspace`)
- `CODEX_AUTH_DIR` (default: `$HOME/.codex`)
- `IMAGE_NAME` (default: `codex-sandbox:latest`)
- `DOCKERFILE_PATH` (default: `<script-dir>/Dockerfile`)
- `CONTAINER_NAME` (default: hash from `SOURCE_DIR`)

## Notes

- Keep `SOURCE_DIR` scoped to what Codex should modify.
- If Docker is not running, commands will fail until Docker starts.
- `sb install-tools` reads `.tool-versions`, adds missing asdf plugins, and runs `asdf install`.
- Installed tool versions are cached by the persistent per-`SOURCE_DIR` container.
- To fully reset a repo sandbox: `SOURCE_DIR=/path sb destroy`.

## License

MIT. See `LICENSE`.
