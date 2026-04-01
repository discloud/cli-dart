#!/bin/bash

set -e

echo "Installing Discloud CLI..."

OS=$(uname -s)
ARCH=$(uname -m)

echo "$OS $ARCH"

# Detect OS
case "$OS" in
  Linux)
    PLATFORM="linux"
    ;;
  Darwin)
    PLATFORM="macos"
    ;;
  *)
    echo "Unsupported OS: $OS"
    exit 1
    ;;
esac

# Detect ARCH
case "$ARCH" in
  x86_64)
    ARCH_SUFFIX="x64"
    ;;
  aarch64|arm64)
    ARCH_SUFFIX="arm64"
    ;;
  *)
    echo "Unsupported architecture: $ARCH"
    exit 1
    ;;
esac

ARCHIVE="discloud-cli-$PLATFORM-$ARCH_SUFFIX.tar.gz"

# Get latest version
VERSION=$(curl -s https://api.github.com/repos/discloud/cli-dart/releases/latest | grep '"tag_name"' | cut -d'"' -f4)

if [ -z VERSION ]; then
  echo "Failed to fetch latest version"
  exit 1
fi

echo "Version: $VERSION"

DOWNLOAD_URL="https://github.com/discloud/cli-dart/releases/download/$VERSION/$ARCHIVE"
echo "Download URL: $DOWNLOAD_URL"

echo "Downloading..."
curl -fSL -o discloud-cli.tar.gz "$DOWNLOAD_URL"

echo "Download complete"

# Extract
echo "Extracting..."
tar -xzf discloud-cli.tar.gz
rm -f discloud-cli.tar.gz

# Install
if [ ! -f "discloud/discloud" ]; then
  echo "Binary 'discloud' not found after extraction"
  exit 1
fi

chmod +x discloud/discloud
echo "Binary executable"

sudo mv discloud/discloud /usr/local/bin/discloud
echo "Installed to /usr/local/bin/discloud"

rmdir discloud

echo "Done! Run 'discloud --version' to verify."
