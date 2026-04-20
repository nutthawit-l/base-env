#!/bin/bash

# Use current directory name as container name
CONTAINER_NAME=$(basename "$PWD")

# Validate folder name
if [ -z "$CONTAINER_NAME" ]; then
    echo "Error: Could not determine current folder name. Aborting."
    exit 1
fi

# Check if Makefile already exists
if [ -f Makefile ]; then
    read -p "Makefile already exists. Overwrite? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
    fi
fi

# Generate the Makefile
cat > Makefile << EOF
CONTAINER_NAME = $CONTAINER_NAME

build: link-ssh
	distrobox assemble create

clean:
	distrobox assemble rm

rebuild: clean build

enter:
	distrobox enter \$(CONTAINER_NAME)

enter-v:
	distrobox enter -v \$(CONTAINER_NAME)

link-ssh:
	ls -svf ~/.ssh .

# The following commands must be executed within a Distrobox container

define VSCODE_SOURCE
Types: deb
URIs: https://packages.microsoft.com/repos/code
Suites: stable
Components: main
Architectures: amd64,arm64,armhf
Signed-By: /usr/share/keyrings/microsoft.gpg
endef
export VSCODE_SOURCE

install-vscode:
	sudo apt-get install -y wget gpg && \\
	wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg && \\
	sudo install -D -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/microsoft.gpg && \\
	rm -f microsoft.gpg
	@echo "\$\$VSCODE_SOURCE" | sudo tee /etc/apt/sources.list.d/vscode.sources > /dev/null
	sudo apt install -y apt-transport-https && sudo apt update && sudo apt install -y code

install-claude:
	curl -fsSL https://claude.ai/install.sh | bash

EOF

echo "Makefile generated successfully with:"
echo "  CONTAINER_NAME  = $CONTAINER_NAME (from current directory)"