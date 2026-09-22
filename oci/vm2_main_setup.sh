#!/bin/bash
set -euo pipefail

CORE=/home/ubuntu/projects/algo-trading-core
OPS=/home/ubuntu/projects/algo-trading-ops

APPROVED_UNITS=(
  algo_health_agent.service
  algo_health_agent_eod.service
  algo_health_agent_morning.service
  eod_screener.service
  intraday_scan.service
  paper_monitor.service
  preflight.service
  telegram_command_listener.service
  algo_health_agent_check.timer
  algo_health_agent_eod.timer
  algo_health_agent_morning.timer
  eod_screener.timer
  intraday_scan.timer
  paper_monitor.timer
  preflight.timer
)

sudo apt-get update
sudo apt-get install -y python3-pip python3-venv git systemd curl

cd "$CORE"
python3 -m venv .venv
.venv/bin/pip install --upgrade pip
.venv/bin/pip install -e ".[dev]"

for unit in "${APPROVED_UNITS[@]}"; do
  sudo install -m 0644 "$OPS/systemd/$unit" "/etc/systemd/system/$unit"
done

# The old localhost:8080 watchdog is not part of the approved deployment.
sudo systemctl disable --now watchdog.timer watchdog.service 2>/dev/null || true
sudo rm -f \
  /etc/systemd/system/watchdog.timer \
  /etc/systemd/system/watchdog.service

sudo touch /etc/algo-trading-primary-runtime
sudo systemctl daemon-reload

sudo systemctl enable --now \
  telegram_command_listener.service \
  preflight.timer \
  intraday_scan.timer \
  paper_monitor.timer \
  eod_screener.timer \
  algo_health_agent_morning.timer \
  algo_health_agent_check.timer \
  algo_health_agent_eod.timer

echo "Paper-trading services installed."
systemctl status telegram_command_listener.service --no-pager
systemctl list-timers --all | grep -E \
'preflight|intraday_scan|paper_monitor|eod_screener|algo_health_agent' || true
