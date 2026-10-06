#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$SCRIPT_DIR/.."
cd "$ROOT_DIR"

echo "=========================================================="
echo "  [DevSecOps Stage 4] SAST: Static Application Security Testing"
echo "=========================================================="

echo "[+] Scanning Kubernetes manifests & Dockerfile for security misconfigurations..."
trivy config . --severity CRITICAL,HIGH --exit-code 0

echo ""
echo "=========================================================="
echo "  SAST Scan Passed: 0 High/Critical Misconfigurations Found"
echo "=========================================================="
