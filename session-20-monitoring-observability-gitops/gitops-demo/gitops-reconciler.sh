#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="gitops-demo"
GIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/git-repo/apps" && pwd)"
MANIFEST="$GIT_DIR/frontend-app.yaml"

echo "=========================================================="
echo "          GITOPS CONTINUOUS RECONCILIATION ENGINE         "
echo "=========================================================="
echo "Source of Truth (Git): $MANIFEST"
echo "Target Cluster Namespace: $NAMESPACE"

# Ensure namespace exists
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f - >/dev/null

reconcile() {
  echo -e "\n--> [RECONCILE LOOP] Checking cluster state against Git source of truth..."
  
  # Extract desired replicas from Git manifest
  DESIRED_REPLICAS=$(grep 'replicas:' "$MANIFEST" | head -n 1 | awk '{print $2}')
  
  # Check if deployment exists in cluster
  if kubectl get deployment gitops-frontend-app -n "$NAMESPACE" >/dev/null 2>&1; then
    LIVE_REPLICAS=$(kubectl get deployment gitops-frontend-app -n "$NAMESPACE" -o jsonpath='{.spec.replicas}')
    LIVE_IMAGE=$(kubectl get deployment gitops-frontend-app -n "$NAMESPACE" -o jsonpath='{.spec.template.spec.containers[0].image}')
    DESIRED_IMAGE=$(grep 'image:' "$MANIFEST" | head -n 1 | awk '{print $2}')
    
    echo "    Git Desired State: replicas=$DESIRED_REPLICAS, image=$DESIRED_IMAGE"
    echo "    Live Cluster State: replicas=$LIVE_REPLICAS, image=$LIVE_IMAGE"
    
    if [ "$LIVE_REPLICAS" -ne "$DESIRED_REPLICAS" ] || [ "$LIVE_IMAGE" != "$DESIRED_IMAGE" ]; then
      echo -e "\n[!] WARNING: CONFIGURATION DRIFT DETECTED!"
      echo "    Cluster diverged from Git (Live: replicas=$LIVE_REPLICAS vs Git: replicas=$DESIRED_REPLICAS)"
      echo "--> [SELF-HEALING] Reconciling cluster state back to Git Source of Truth..."
      kubectl apply -f "$MANIFEST"
      kubectl rollout status deployment/gitops-frontend-app -n "$NAMESPACE" --timeout=30s
      echo "[✓] SUCCESS: Cluster state self-healed and reconciled to Git source of truth!"
    else
      echo "[✓] IN-SYNC: Live cluster matches Git desired state perfectly."
    fi
  else
    echo "--> [INITIAL SYNC] Deployment not found in cluster. Applying from Git..."
    kubectl apply -f "$MANIFEST"
    kubectl rollout status deployment/gitops-frontend-app -n "$NAMESPACE" --timeout=30s
    echo "[✓] Initial GitOps sync complete."
  fi
}

case "${1:-reconcile}" in
  reconcile)
    reconcile
    ;;
  *)
    echo "Usage: $0 {reconcile}"
    exit 1
    ;;
esac
