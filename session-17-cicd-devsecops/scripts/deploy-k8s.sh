#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$SCRIPT_DIR/.."
cd "$ROOT_DIR"

NAMESPACE="devsecops-prod"

echo "=========================================================="
echo "  [DevSecOps Stage 10 & 11] Image Push & Kubernetes Deployment"
echo "=========================================================="

echo "[+] Step 1: Loading verified secure image into cluster..."
minikube image load vaultshield-api:v1.0.0

echo ""
echo "[+] Step 2: Enforcing Namespace & Hardened Pod Security Standards..."
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
kubectl label namespace "$NAMESPACE" pod-security.kubernetes.io/enforce=restricted --overwrite

echo ""
echo "[+] Step 3: Applying Kubernetes Manifests..."
kubectl apply -f k8s/

echo ""
echo "[+] Step 4: Awaiting Deployment Zero-Downtime Rollout..."
kubectl rollout status deployment/vaultshield-api -n "$NAMESPACE" --timeout=60s

echo ""
echo "[+] Step 5: Querying Pods and Security Context..."
kubectl get deployments,pods,services -n "$NAMESPACE" -l app=vaultshield-api

echo ""
echo "[+] Step 6: Post-Deployment Security Smoke Test..."
POD_NAME=$(kubectl get pods -n "$NAMESPACE" -l app=vaultshield-api -o jsonpath="{.items[0].metadata.name}")
echo "Testing target Pod: $POD_NAME"
kubectl exec "$POD_NAME" -n "$NAMESPACE" -- wget -qO- http://127.0.0.1:3000/
echo ""
kubectl exec "$POD_NAME" -n "$NAMESPACE" -- wget -qO- http://127.0.0.1:3000/health
echo ""

echo "=========================================================="
echo "  DevSecOps Deployment Verified Healthy!"
echo "=========================================================="
