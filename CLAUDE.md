# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

This is a **template repository**, not an application. It bootstraps a per-project Distrobox-based development environment by generating two artifacts into the consuming project's working directory:

- `Makefile` — distrobox lifecycle targets + tool installers (vscode, gh, claude, cursor)
- `distrobox.ini` — distrobox-assemble config naming the container after the current directory

The expected workflow is to `git clone` this repo under a new project name, run the generators, delete `.git`, then `git init` a fresh history. See `README.md` for the full bootstrap sequence.

## Generators

Both scripts derive the container/profile name from `basename "$PWD"` — the current directory name *is* the container name. There is no flag to override this; rename the directory if you want a different container name.

- `./gen_makefile.sh` — no args. Writes `Makefile`, prompts before overwriting.
- `./gen_distrobox.sh {ubuntu-lts|fedora}` — required arg picks the base image (`docker.io/jrei/systemd-ubuntu:24.04` or `docker.io/jrei/systemd-fedora:latest`). Writes `distrobox.ini` with `home=` set to the absolute path of `$PWD`. Running with no args prints help and exits 1.

When editing the generators, note that `gen_makefile.sh` writes the Makefile via a quoted heredoc with a `CONTAINER_NAME_PLACEHOLDER` that is then `sed`-replaced — so `$(...)` and `$$` inside the Makefile body are preserved literally. `gen_distrobox.sh` uses the same placeholder pattern for `IMAGE_PLACEHOLDER` and `CURRENT_DIR_PLACEHOLDER`.

## Generated Makefile targets

The generated Makefile splits targets into two groups:

- **Host targets** (run outside the container): `build`, `clean`, `stop`, `rebuild`, `enter`, `enter-v`, `link-ssh`, `link-gitconfig`. `build` depends on `link-ssh` and `link-gitconfig`, which symlink the host's `~/.ssh` and `~/.gitconfig` into the project dir so distrobox-assemble can mount them.
- **In-container targets** (must be run from inside `make enter`): `install-vscode`, `install-gh`, `install-claude`, `install-cursor`. Each dispatches to a debian or fedora variant based on `/etc/debian_version` / `/etc/fedora-release` / `/etc/redhat-release`. When adding a new installer, follow the same OS-detection pattern.

## VSCode config carve-out

`.gitignore` blacklists the entire home dir but uses `!`-rules to whitelist exactly `.config/Code/User/settings.json` and `.config/Code/User/keybindings.json`. If you add another VSCode file you want tracked (snippets, tasks, etc.), add a matching `!`-rule — a plain `git add` on a path inside `.config/` will be silently ignored otherwise.

## Testing changes

There is no test suite. To validate generator changes, run them in a scratch directory and inspect the output:

```sh
mkdir /tmp/scratch-env && cd /tmp/scratch-env
/path/to/base-env/gen_makefile.sh
/path/to/base-env/gen_distrobox.sh fedora
```

End-to-end validation requires `distrobox` and a container runtime (podman/docker) on the host.