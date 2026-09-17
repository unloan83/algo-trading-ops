#!/bin/bash
# OCI Always Free VM2 (Ampere A1 Flex 1 OCPU / 6 GB RAM) Provisioning Script

set -euo pipefail

echo "Installing core dependencies on VM2..."
sudo apt-get update
sudo apt-get install -y python3-pip python3-venv postgresql postgresql-contrib git systemd curl

echo "Setting up local PostgreSQL database for trade journal..."
sudo -u postgres psql -c "CREATE DATABASE trading_db;" || true
sudo -u postgres psql -c "CREATE USER trader WITH PASSWORD 'local_secure_pass';" || true
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE trading_db TO trader;" || true

echo "Configuring systemd service timers..."
sudo cp systemd/*.service /etc/systemd/system/
sudo cp systemd/*.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now eod_screener.timer watchdog.timer

echo "VM2 setup complete."
