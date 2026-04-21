#!/bin/bash

# Show help message
show_help() {
    cat << EOF
Usage: $0 {ubuntu-lts|fedora}

Generate a distrobox.ini configuration file for the specified base OS.

Arguments:
  ubuntu-lts  - Use Ubuntu 24.04 LTS (image: docker.io/jrei/systemd-ubuntu:24.04)
  fedora      - Use Fedora (image: docker.io/jrei/systemd-fedora:latest)

If no argument is provided, this help message is shown.

Examples:
  $0 ubuntu-lts
  $0 fedora
EOF
    exit 1
}

# Check if argument is provided
if [ $# -eq 0 ]; then
    show_help
fi

# Set image based on argument
case "$1" in
    ubuntu-lts)
        IMAGE="docker.io/jrei/systemd-ubuntu:24.04"
        ;;
    fedora)
        IMAGE="docker.io/jrei/systemd-fedora:latest"
        ;;
    *)
        echo "Error: Invalid option '$1'"
        show_help
        ;;
esac

# Template content with placeholder for full current directory path and image
read -r -d '' TEMPLATE << 'EOF'
[base-env]
additional_packages="git make"
image=IMAGE_PLACEHOLDER
init=true
home=CURRENT_DIR_PLACEHOLDER
replace=false
root=false
init_hooks=sudo ln -sfv /usr/bin/distrobox-host-exec /usr/local/bin/xdg-open;
EOF

# Get current folder name (basename) and full absolute path
NEW_NAME=$(basename "$PWD")
FULL_PATH=$(pwd)

# Validate
if [ -z "$NEW_NAME" ] || [ -z "$FULL_PATH" ]; then
    echo "Error: Could not determine current folder name or path. Aborting."
    exit 1
fi

# Output file name
OUTPUT_FILE="distrobox.ini"

# Replace placeholders: base-env -> folder name, IMAGE_PLACEHOLDER -> actual image, CURRENT_DIR_PLACEHOLDER -> full path
echo "$TEMPLATE" | sed -e "s/base-env/${NEW_NAME}/g" -e "s|IMAGE_PLACEHOLDER|${IMAGE}|g" -e "s|CURRENT_DIR_PLACEHOLDER|${FULL_PATH}|g" > "$OUTPUT_FILE"

echo "Distrobox configuration generated: $OUTPUT_FILE"
echo "Using current folder name: $NEW_NAME"
echo "Base OS: $1 (image: $IMAGE)"
echo "Home directory set to: $FULL_PATH"
echo "Content:"
cat "$OUTPUT_FILE"