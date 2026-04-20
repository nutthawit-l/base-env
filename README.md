# Makefile & Distrobox Config Generator

This repository provides two Bash scripts to simplify the creation of:

- A **Makefile** with predefined variables.
- A **Distrobox configuration file** (`.ini`) from a template, replacing the environment name.

Both scripts are interactive, support command‑line arguments, and ask before overwriting existing files.

---

## Scripts Overview

| Script | Purpose | Output |
|--------|---------|--------|
| `gen_makefile.sh` | Generates a Makefile with user‑provided container_name | `Makefile` |
| `gen_distrobox.sh` | Generates a Distrobox `.ini` config file, replacing `base‑env` with a current directory name | `distrobox.ini` |

---

## Prerequisites

- **Bash** (version 4.0 or higher)
- Common Unix utilities: `sed`, `cat`, `curl`, `wget` (some are used inside the generated files, not by the generators themselves)
- **Distrobox** (if you plan to use the generated Makefile or `.ini` file)

### Usage

1. Clone this project to a different name (e.g., connect-go-example).

```console
git clone https://github.com/nutthawit-l/base-env.git connect-go-example
```

2. In the *connect-go-example* directory. Run the following scripts.

```console
./gen_makefile.sh [container_name]
./gen_distrobox.sh
```