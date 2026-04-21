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
cat > Makefile << 'EOF'
CONTAINER_NAME = CONTAINER_NAME_PLACEHOLDER

build: link-ssh
	distrobox assemble create

clean:
	distrobox assemble rm

rebuild: clean build

enter:
	distrobox enter $(CONTAINER_NAME)

enter-v:
	distrobox enter -v $(CONTAINER_NAME)

link-ssh:
	ln -svf ~/.ssh/ .

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

install-vscode-deb:
	sudo apt-get install -y wget gpg && \
	wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg && \
	sudo install -D -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/microsoft.gpg && \
	rm -f microsoft.gpg
	@echo "$$VSCODE_SOURCE" | sudo tee /etc/apt/sources.list.d/vscode.sources > /dev/null
	sudo apt install -y apt-transport-https && sudo apt update && sudo apt install -y code

install-vscode-rpm:
	sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc && echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
	dnf check-update && sudo dnf install -y code

install-vscode:
	@if [ -f /etc/debian_version ]; then \
		echo "Detected Debian/Ubuntu – using apt method"; \
		$(MAKE) install-vscode-deb; \
	elif [ -f /etc/redhat-release ]; then \
		echo "Detected RHEL/Fedora – using dnf method"; \
		$(MAKE) install-vscode-rpm; \
	else \
		echo "Unsupported OS – cannot install VSCode automatically"; \
		exit 1; \
	fi

install-gh:
	@if [ -f /etc/debian_version ]; then \
		echo "Detected Debian/Ubuntu – using apt method"; \
		$(MAKE) install-gh-deb; \
	elif [ -f /etc/redhat-release ]; then \
		echo "Detected RHEL/Fedora – using dnf method"; \
		$(MAKE) install-gh-rpm; \
	fi

install-gh-deb:
	(type -p wget >/dev/null || (sudo apt update && sudo apt install wget -y)) \
	&& sudo mkdir -p -m 755 /etc/apt/keyrings \
	&& out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
	&& cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
	&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
	&& sudo mkdir -p -m 755 /etc/apt/sources.list.d \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
	&& sudo apt update \
	&& sudo apt install gh -y

install-gh-rpm:
	curl -fsSL -o - https://cli.github.com/packages/githubcli-archive-keyring.asc | gpg --show-keys
	# These commands apply to DNF4 only.
	sudo dnf install 'dnf-command(config-manager)'
	sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
	sudo dnf install gh --repo gh-cli

install-claude:
	curl -fsSL https://claude.ai/install.sh | bash

EOF

# Replace the placeholder with the actual container name
sed -i "s/CONTAINER_NAME_PLACEHOLDER/$CONTAINER_NAME/g" Makefile

echo "Makefile generated successfully with:"
echo "  CONTAINER_NAME  = $CONTAINER_NAME (from current directory)"