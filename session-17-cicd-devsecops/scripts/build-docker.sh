#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$SCRIPT_DIR/.."
cd "$ROOT_DIR"

echo "=========================================================="
echo "  [DevSecOps Stage 7] Docker Build: Hardened Image Packaging"
echo "=========================================================="

echo "[+] Building multi-stage container image: vaultshield-api:v1.0.0..."
docker build -t vaultshield-api:v1.0.0 -t vaultshield-api:latest .

echo ""
echo "[+] Inspecting image security properties..."
docker images vaultshield-api:v1.0.0
docker image inspect vaultshield-api:v1.0.0 --format 'User: {{.Config.User}} | Env: {{.Config.Env}} | Ports: {{.Config.ExposedPorts}}'

echo ""
echo "=========================================================="
echo "  Docker Image Built Successfully!"
echo "=========================================================="
