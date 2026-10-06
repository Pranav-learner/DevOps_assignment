#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="cloudstore-system"
RELEASE_NAME="cloudstore"
CHART_DIR="../cloudstore-chart"
NEW_TAG="${1:-1.27-alpine}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=========================================================="
echo "  Upgrading CloudStore Release to Image Tag: ${NEW_TAG}"
echo "=========================================================="

helm upgrade "$RELEASE_NAME" "$CHART_DIR" \
  --namespace "$NAMESPACE" \
  -f "$CHART_DIR/values-prod.yaml" \
  --set image.tag="$NEW_TAG" \
  --set config.appEnv="production-canary"

echo "[+] Waiting for rolling update rollout..."
kubectl rollout status deployment/"${RELEASE_NAME}-cloudstore-chart" -n "$NAMESPACE" --timeout=90s

echo "=========================================================="
echo "  Upgrade Completed Successfully! Current Revisions:"
echo "=========================================================="
helm history "$RELEASE_NAME" -n "$NAMESPACE"
