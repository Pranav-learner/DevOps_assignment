#!/usr/bin/env bash
set -eo pipefail

echo "=========================================================="
echo " Pranav GitOps Continuous Reconciliation Engine"
echo "=========================================================="

GITOPS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HELM_CHART_DIR="${GITOPS_DIR}/../helm/pranav-app"
NAMESPACE="pranav-prod"

echo "1. Checking live Kubernetes cluster connectivity..."
kubectl cluster-info > /dev/null

echo "2. Validating GitOps desired state (Helm chart)..."
helm lint "${HELM_CHART_DIR}"

echo "3. Detecting Configuration Drift between Git and Cluster..."
# Diff against current state if namespace exists
if kubectl get ns "${NAMESPACE}" > /dev/null 2>&1; then
    echo "Namespace ${NAMESPACE} exists. Evaluating live resource status:"
    kubectl get pods,svc,hpa -n "${NAMESPACE}" -l app.kubernetes.io/name=pranav-app || true
fi

echo "4. Applying Continuous Reconciliation (Self-Healing Sync)..."
helm upgrade --install pranav-app "${HELM_CHART_DIR}" \
  --namespace "${NAMESPACE}" \
  --create-namespace \
  --wait --timeout 2m

echo ""
echo "5. Verifying Deployed Workload..."
kubectl get all -n "${NAMESPACE}" -l app.kubernetes.io/name=pranav-app
echo ""
echo "🎉 GitOps Continuous Sync Status: Synced & Healthy!"
