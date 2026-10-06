#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$SCRIPT_DIR/.."
cd "$ROOT_DIR"

NAMESPACE="cicd-demo"

echo "=========================================================="
echo "  [CD Stage 2] Kubernetes Deployment & Verification"
echo "=========================================================="

echo "[+] Step 1: Loading Docker Image into Minikube Cluster..."
minikube image load taskpulse-api:v1.0.0

echo ""
echo "[+] Step 2: Creating Namespace & Applying Manifests..."
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f k8s/

echo ""
echo "[+] Step 3: Awaiting Zero-Downtime Deployment Rollout..."
kubectl rollout status deployment/taskpulse-api -n "$NAMESPACE" --timeout=60s

echo ""
echo "[+] Step 4: Inspecting Pods & Service..."
kubectl get deployments,pods,services -n "$NAMESPACE" -l app=taskpulse-api

echo ""
echo "[+] Step 5: Executing Automated Smoke Test via Pod Curl..."
POD_NAME=$(kubectl get pods -n "$NAMESPACE" -l app=taskpulse-api -o jsonpath="{.items[0].metadata.name}")
echo "Target Pod: $POD_NAME"
kubectl exec "$POD_NAME" -n "$NAMESPACE" -- wget -qO- http://127.0.0.1:3000/
echo ""
kubectl exec "$POD_NAME" -n "$NAMESPACE" -- wget -qO- http://127.0.0.1:3000/health
echo ""

echo "=========================================================="
echo "  Kubernetes CD Rollout & Smoke Test Succeeded!"
echo "=========================================================="
