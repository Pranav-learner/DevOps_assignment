#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="cloudstore-system"
RELEASE_NAME="cloudstore"
CHART_DIR="../cloudstore-chart"
ENV_PROFILE="${1:-prod}" # default to prod or staging

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=========================================================="
echo "  Deploying CloudStore Platform (${ENV_PROFILE}) via Helm"
echo "=========================================================="

# 1. Lint the chart
echo "[+] Linting Helm Chart..."
helm lint "$CHART_DIR"

# 2. Select values file
VALUES_FILE="$CHART_DIR/values-${ENV_PROFILE}.yaml"
if [[ ! -f "$VALUES_FILE" ]]; then
  VALUES_FILE="$CHART_DIR/values.yaml"
fi
echo "[+] Utilizing values file: $VALUES_FILE"

# 3. Install / Upgrade release
echo "[+] Executing helm upgrade --install..."
helm upgrade --install "$RELEASE_NAME" "$CHART_DIR" \
  --namespace "$NAMESPACE" \
  --create-namespace \
  -f "$VALUES_FILE"

# 4. Wait for deployment rollout
echo "[+] Waiting for deployment rollout..."
kubectl rollout status deployment/"${RELEASE_NAME}-cloudstore-chart" -n "$NAMESPACE" --timeout=90s

echo "=========================================================="
echo "  Deployment Completed Successfully!"
echo "=========================================================="
