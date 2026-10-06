#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="cloudstore-system"
RELEASE_NAME="cloudstore"

echo "=========================================================="
echo "  Tearing down CloudStore Release & Namespace"
echo "=========================================================="

if helm status "$RELEASE_NAME" -n "$NAMESPACE" &>/dev/null; then
  echo "[+] Uninstalling Helm release: $RELEASE_NAME"
  helm uninstall "$RELEASE_NAME" -n "$NAMESPACE"
fi

if kubectl get ns "$NAMESPACE" &>/dev/null; then
  echo "[+] Deleting namespace: $NAMESPACE"
  kubectl delete ns "$NAMESPACE" --ignore-not-found=true
fi

echo "[+] Teardown Complete."
