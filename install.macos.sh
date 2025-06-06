#!/bin/bash

# One-liner to run this:
# curl -s https://raw.githubusercontent.com/iz9/scripts/master/install.macos.sh | bash

# Create temporary directory
TEMP_DIR=$(mktemp -d)
REPO="iz9/scripts"
BRANCH="main"
DIR="mac"

echo "Creating temporary directory: $TEMP_DIR"

# Download and extract repository directory
curl -L "https://api.github.com/repos/$REPO/tarball/$BRANCH" | \
tar xz --strip=2 -C "$TEMP_DIR" --wildcards "*/mac/*"

# Make scripts executable
chmod -R +x "$TEMP_DIR"

# Run the main installation script
cd "$TEMP_DIR"
./install.mac.sh

# Cleanup
cd
rm -rf "$TEMP_DIR"
