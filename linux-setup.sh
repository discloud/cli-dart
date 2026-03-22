#!/bin/bash

set -e

echo "Installing Discloud CLI..."

ARCH=$(uname -m)
[ "$ARCH" = "x86_64" ] && BINARY="discloud-cli-linux-x64"
[ -z "$BINARY" ] && echo "Unsupported architecture: $ARCH" && exit 1

# Get latest version and download binary
VERSION=$(curl -s https://api.github.com/repos/discloud/cli-dart/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
echo "Downloading $BINARY (v${VERSION})..."
curl -SL -o discloud "https://github.com/discloud/cli-dart/releases/download/${VERSION}/$BINARY"

# Install and cleanup
chmod +x discloud
sudo mv discloud /usr/local/bin/discloud
echo "Done! Run 'discloud --version' to verify."
