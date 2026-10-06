#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RECONCILER="$SCRIPT_DIR/gitops-reconciler.sh"
MANIFEST="$SCRIPT_DIR/git-repo/apps/frontend-app.yaml"
NAMESPACE="gitops-demo"

chmod +x "$RECONCILER"

echo "=========================================================="
echo "         STEP 1: INITIAL GITOPS SYNCHRONIZATION           "
echo "=========================================================="
# Ensure manifest starts with 2 replicas
sed -i 's/replicas: .*/replicas: 2/' "$MANIFEST"
bash "$RECONCILER" reconcile
kubectl get pods -n "$NAMESPACE"

echo -e "\n=========================================================="
echo "    STEP 2: MANUAL TAMPERING / DRIFT INJECTION DRILL      "
echo "=========================================================="
echo "Simulating unauthorized manual drift: scaling deployment imperatively to 5 replicas..."
kubectl scale deployment gitops-frontend-app -n "$NAMESPACE" --replicas=5
sleep 3
echo "Current live cluster pods after manual tampering:"
kubectl get deployment gitops-frontend-app -n "$NAMESPACE" -o jsonpath='{.spec.replicas} {" replicas in live cluster\n"}'

echo -e "\n=========================================================="
echo "    STEP 3: CONTINUOUS RECONCILIATION & SELF-HEALING      "
echo "=========================================================="
echo "Executing GitOps Reconciler to detect drift and restore Git state..."
bash "$RECONCILER" reconcile
kubectl get pods -n "$NAMESPACE"

echo -e "\n=========================================================="
echo "  STEP 4: DECLARATIVE GIT COMMIT & AUTOMATED ROLLOUT      "
echo "=========================================================="
echo "Simulating developer committing desired state change to Git: updating replicas from 2 to 3..."
sed -i 's/replicas: 2/replicas: 3/' "$MANIFEST"
echo "Git manifest updated: $(grep 'replicas:' "$MANIFEST")"
echo "Triggering GitOps reconciliation loop..."
bash "$RECONCILER" reconcile
kubectl get pods -n "$NAMESPACE"

echo -e "\n[✓] GITOPS WORKFLOW DEMO COMPLETED SUCCESSFULLY!"
