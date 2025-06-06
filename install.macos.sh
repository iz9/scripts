#!/bin/bash

# One-liner to run this:
# curl -s https://raw.githubusercontent.com/iz9/scripts/master/install.macos.sh | bash

# Create temporary directory
TEMP_DIR="$HOME/tmpinstall"
REPO="iz9/scripts"
BRANCH="master"
DIR="mac"

echo "Creating temporary directory: $TEMP_DIR"
mkdir "$TEMP_DIR"

# Download and extract repository directory (macOS compatible)
curl -L "https://api.github.com/repos/$REPO/tarball/$BRANCH" | \
tar xz -C "$TEMP_DIR"

# Find and move mac directory contents
MAC_DIR=$(find "$TEMP_DIR" -type d -name "mac" | head -n 1)
if [ -d "$MAC_DIR" ]; then
    mv "$MAC_DIR"/* "$TEMP_DIR/"
    find "$TEMP_DIR" -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} +
fi

# Make scripts executable
chmod -R +x "$TEMP_DIR"

# Run the main installation script
cd "$TEMP_DIR"
./install.mac.sh "$TEMP_DIR"

# Cleanup
#cd
#rm -rf "$TEMP_DIR"
