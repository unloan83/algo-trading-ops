#!/bin/bash
set -euo pipefail

CORE=/home/user/projects/algo-trading-core
OPS=/home/user/projects/algo-trading-ops

sudo apt-get update
sudo apt-get install -y python3-pip python3-venv git systemd curl

cd "$CORE"
python3 -m venv .venv
.venv/bin/pip install --upgrade pip
.venv/bin/pip install -e ".[dev]"

sudo cp "$OPS"/systemd/*.service /etc/systemd/system/
sudo cp "$OPS"/systemd/*.timer /etc/systemd/system/
sudo systemctl daemon-reload

# The old localhost:8080 watchdog is intentionally NOT enabled:
# there is no health server in the current paper build, and live orders are disabled.
sudo systemctl disable --now watchdog.timer 2>/dev/null || true

sudo systemctl enable --now \
  preflight.timer \
  intraday_scan.timer \
  paper_monitor.timer \
  eod_screener.timer

echo "Paper-trading services installed."
systemctl list-timers --all | grep -E 'preflight|intraday_scan|paper_monitor|eod_screener' || true
