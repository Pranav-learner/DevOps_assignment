#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="cloudstore-system"
RELEASE_NAME="cloudstore"

echo "=========================================================="
echo "  Verifying CloudStore Platform Health in ${NAMESPACE}"
echo "=========================================================="

echo "[+] Release Status:"
helm status "$RELEASE_NAME" -n "$NAMESPACE"

echo ""
echo "[+] Kubernetes Workloads:"
kubectl get deployments,pods,services,ingress,hpa -n "$NAMESPACE"

echo ""
echo "[+] Ingress Details & Endpoints:"
kubectl get endpoints "${RELEASE_NAME}-cloudstore-chart" -n "$NAMESPACE"

echo ""
echo "[+] Testing Internal HTTP Service Connectivity:"
POD_NAME=$(kubectl get pods -n "$NAMESPACE" -l "app.kubernetes.io/instance=${RELEASE_NAME}" -o jsonpath="{.items[0].metadata.name}")
kubectl exec "$POD_NAME" -n "$NAMESPACE" -- wget -qO- http://localhost:80 | head -n 12

echo ""
echo "=========================================================="
echo "  CloudStore Platform Verification Passed!"
echo "=========================================================="
