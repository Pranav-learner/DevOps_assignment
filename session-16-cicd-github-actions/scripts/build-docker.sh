#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$SCRIPT_DIR/.."
cd "$ROOT_DIR"

echo "=========================================================="
echo "  [CD Stage 1] Multi-Stage Docker Container Build"
echo "=========================================================="

echo "[+] Building Production Image: taskpulse-api:v1.0.0..."
docker build -t taskpulse-api:v1.0.0 -t taskpulse-api:latest .

echo ""
echo "[+] Inspecting Container Image Size & Layers..."
docker images taskpulse-api:v1.0.0

echo ""
echo "[+] Verifying Non-Root User & Hardened Configuration..."
docker image inspect taskpulse-api:v1.0.0 --format 'User: {{.Config.User}} | Env: {{.Config.Env}} | Ports: {{.Config.ExposedPorts}}'

echo ""
echo "=========================================================="
echo "  Docker Build Completed Successfully!"
echo "=========================================================="
