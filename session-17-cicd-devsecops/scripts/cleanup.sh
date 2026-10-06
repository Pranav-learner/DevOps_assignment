#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="devsecops-prod"

echo "=========================================================="
echo "  Cleaning up DevSecOps Resources"
echo "=========================================================="

if kubectl get ns "$NAMESPACE" &>/dev/null; then
  echo "[+] Deleting Kubernetes namespace: $NAMESPACE..."
  kubectl delete ns "$NAMESPACE" --ignore-not-found=true
fi

echo "[+] Removing local docker images..."
docker rmi vaultshield-api:v1.0.0 vaultshield-api:latest 2>/dev/null || true

echo "[+] Cleanup Complete."
