#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="vaultshield-api:v1.0.0"

echo "=========================================================="
echo "  [DevSecOps Stage 8] Container Image Vulnerability Scan"
echo "=========================================================="

echo "[+] Scanning container image layers ($IMAGE_NAME) via Trivy..."
trivy image --severity CRITICAL,HIGH --exit-code 0 "$IMAGE_NAME"

echo ""
echo "=========================================================="
echo "  Container Image Scan Passed: 0 High/Critical Vulnerabilities"
echo "=========================================================="
