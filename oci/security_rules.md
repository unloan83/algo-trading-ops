# OCI Security & Cost Tripwire Setup Guide

## 1. OCI Always Free Cost Alert Tripwire
- Log into OCI Console -> Billing & Cost Management -> Budgets.
- Create a Budget with Target: **Tenant**.
- Set Monthly Threshold Amount: **$0.01**.
- Add Alert Rule: Send email / SMS immediately at **100% of threshold ($0.01)**.
- This ensures any accidental paid SKU usage is caught on day 1.

## 2. VCN Firewall & Static IP Whitelisting
- VM2 static public IP must be whitelisted in broker developer portal (Upstox / Fyers / Dhan).
- Security List Ingress Rules:
  - Allow Port 22 (SSH) **ONLY** from your local admin IP.
  - Reject all other incoming ports (Telegram uses long-polling via outbound HTTPS, no inbound port 443 required).
  - `telegram_command_listener.service` is the sole Telegram `getUpdates` consumer; approval callbacks are routed through the local SQLite inbox so scheduled scanners never compete for the bot offset.
