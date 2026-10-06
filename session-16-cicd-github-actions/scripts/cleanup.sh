#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="cicd-demo"

echo "=========================================================="
echo "  Cleaning up CI/CD Demo Resources"
echo "=========================================================="

if kubectl get ns "$NAMESPACE" &>/dev/null; then
  echo "[+] Deleting Kubernetes namespace: $NAMESPACE..."
  kubectl delete ns "$NAMESPACE" --ignore-not-found=true
fi

echo "[+] Removing local docker images..."
docker rmi taskpulse-api:v1.0.0 taskpulse-api:latest 2>/dev/null || true

echo "[+] CI/CD Demo Cleanup Complete."
