#!/bin/bash

set -e

NODE_EXPORTER_VERSION="1.8.2"
ARCH="$(uname -m)"

if [[ "$ARCH" == "x86_64" ]]; then
    ARCH="linux-amd64"
elif [[ "$ARCH" == "aarch64" ]]; then
    ARCH="linux-arm64"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

DOWNLOAD_URL="https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.${ARCH}.tar.gz"
INSTALL_DIR="/usr/local/bin"
SERVICE_FILE="/etc/systemd/system/node_exporter.service"

# Create node_exporter user
sudo useradd --no-create-home --shell /bin/false node_exporter || true

# Download and install Node Exporter
wget "$DOWNLOAD_URL" -O /tmp/node_exporter.tar.gz
tar -xzf /tmp/node_exporter.tar.gz -C /tmp/
sudo mv /tmp/node_exporter-${NODE_EXPORTER_VERSION}.${ARCH}/node_exporter "$INSTALL_DIR"
sudo chown node_exporter:node_exporter "$INSTALL_DIR/node_exporter"

# Cleanup
rm -rf /tmp/node_exporter.tar.gz /tmp/node_exporter-${NODE_EXPORTER_VERSION}.${ARCH}

# Create systemd service file
echo "[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=$INSTALL_DIR/node_exporter

[Install]
WantedBy=multi-user.target" | sudo tee "$SERVICE_FILE"

# Reload systemd, start and enable Node Exporter
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter

# Check status
sudo systemctl status node_exporter --no-pager
