#!/bin/bash

# Template content with placeholder for full current directory path
read -r -d '' TEMPLATE << 'EOF'
[base-env]
additional_packages="git gh make"
image=docker.io/almalinux/10-init
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

# Replace 'base-env' with folder name AND placeholder with full path
echo "$TEMPLATE" | sed -e "s/base-env/${NEW_NAME}/g" -e "s|CURRENT_DIR_PLACEHOLDER|${FULL_PATH}|g" > "$OUTPUT_FILE"

echo "Distrobox configuration generated: $OUTPUT_FILE"
echo "Using current folder name: $NEW_NAME"
echo "Home directory set to: $FULL_PATH"
echo "Content:"
cat "$OUTPUT_FILE"