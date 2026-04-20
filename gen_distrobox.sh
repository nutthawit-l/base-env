#!/bin/bash

# Template content
read -r -d '' TEMPLATE << 'EOF'
[base-env]
additional_packages="git make"
image=docker.io/almalinux/10-init
init=true
home=${HOME}/base-env
replace=false
root=false
init_hooks=sudo ln -sfv /usr/bin/distrobox-host-exec /usr/local/bin/xdg-open;
EOF

# Get current folder name (basename of working directory)
NEW_NAME=$(basename "$PWD")

# Validate folder name (cannot be empty or contain problematic characters)
if [ -z "$NEW_NAME" ]; then
    echo "Error: Could not determine current folder name. Aborting."
    exit 1
fi

# Output file name
OUTPUT_FILE="distrobox.ini"

# Replace all 'base-env' with current folder name (including in the home path)
echo "$TEMPLATE" | sed "s/base-env/${NEW_NAME}/g" > "$OUTPUT_FILE"

echo "Distrobox configuration generated: $OUTPUT_FILE"
echo "Using current folder name: $NEW_NAME"
echo "Content:"
cat "$OUTPUT_FILE"