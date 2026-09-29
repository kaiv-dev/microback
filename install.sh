#!/usr/bin/env bash
set -euo pipefail

PREFIX="${PREFIX:-/usr/local}"
BIN_DIR="${PREFIX}/bin"

echo "=== Installing microback to ${BIN_DIR}/microback ==="

mkdir -p "${BIN_DIR}"
install -m 755 microback "${BIN_DIR}/microback"

mkdir -p /etc/microback/configs
mkdir -p /etc/microback/enabled.d
mkdir -p /var/log/microback
mkdir -p /var/lib/microback

echo "Installed successfully!"
echo "Run 'microback --help' to get started."
