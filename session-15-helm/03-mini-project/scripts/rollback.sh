#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="cloudstore-system"
RELEASE_NAME="cloudstore"
TARGET_REVISION="${1:-1}"

echo "=========================================================="
echo "  Executing Helm Rollback to Target Revision: ${TARGET_REVISION}"
echo "=========================================================="

helm rollback "$RELEASE_NAME" "$TARGET_REVISION" --namespace "$NAMESPACE"

echo "[+] Waiting for rollback deployment rollout..."
kubectl rollout status deployment/"${RELEASE_NAME}-cloudstore-chart" -n "$NAMESPACE" --timeout=90s

echo "=========================================================="
echo "  Rollback Completed Successfully! History:"
echo "=========================================================="
helm history "$RELEASE_NAME" -n "$NAMESPACE"
